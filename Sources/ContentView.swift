import SwiftUI
import ReplayKit
import PhotosUI
import CoreTransferable

private struct PickedVideo: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .movie) { received in
            let fileExtension = received.file.pathExtension.isEmpty ? "mov" : received.file.pathExtension
            let destinationURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("picked-video-\(UUID().uuidString)")
                .appendingPathExtension(fileExtension)

            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }

            try FileManager.default.copyItem(at: received.file, to: destinationURL)
            return Self(url: destinationURL)
        }
    }
}

struct SystemBroadcastPickerView: UIViewRepresentable {
    let preferredExtension: String

    func makeUIView(context: Context) -> RPSystemBroadcastPickerView {
        let picker = RPSystemBroadcastPickerView(frame: .zero)
        picker.preferredExtension = preferredExtension
        picker.showsMicrophoneButton = true
        return picker
    }

    func updateUIView(_ uiView: RPSystemBroadcastPickerView, context: Context) {
        uiView.preferredExtension = preferredExtension
    }
}

struct ContentView: View {
    @StateObject private var recorder = ScreenRecorderService()
    @EnvironmentObject private var monetization: MonetizationManager
    @State private var micOn = true
    @State private var selectedVideoItem: PhotosPickerItem?
    @State private var exportStatus = "No export started."
    @State private var exportOutputURL: URL?
    @State private var isExporting = false
    @State private var isShowingPaywall = false
    private let isTikTokGateEnabled = AppConfig.FeatureFlags.monetizationEnabled
        && AppConfig.FeatureFlags.gateTikTokExportToPro

    var body: some View {
        VStack(spacing: 16) {
            Text("Screen Recorder MVP")
                .font(.title2).bold()

            if AppConfig.FeatureFlags.monetizationEnabled {
                HStack {
                    if monetization.hasPro {
                        Label("Pro Active", systemImage: "checkmark.seal.fill")
                            .foregroundColor(.green)
                    } else {
                        Button("Upgrade to Pro") {
                            isShowingPaywall = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Spacer()
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Broadcast Entire Screen")
                    .font(.headline)
                Text("Tap the system broadcast button below to start ReplayKit broadcast flow. If prompted, choose \"ScreenRecorderMVP\".")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                HStack {
                    Text("System Broadcast")
                        .font(.subheadline)
                    Spacer()
                    SystemBroadcastPickerView(
                        preferredExtension: "com.example.ScreenRecorderMVP.BroadcastUploadExtension"
                    )
                    .frame(width: 44, height: 44)
                }
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)

            Toggle("Microphone", isOn: $micOn)
                .onChange(of: micOn) { newValue in
                    recorder.setMicrophoneEnabled(newValue)
                }

            if recorder.isRecording {
                Text("Recording...")
                    .foregroundColor(.red)
            }

            HStack(spacing: 12) {
                Button("Start") {
                    recorder.setMicrophoneEnabled(micOn)
                    recorder.start()
                }
                .buttonStyle(.borderedProminent)
                .disabled(recorder.isRecording)

                Button("Stop") {
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let root = scene.windows.first?.rootViewController {
                        recorder.stopAndPreview(from: root)
                    }
                }
                .buttonStyle(.bordered)
                .disabled(!recorder.isRecording)
            }

            if let err = recorder.lastError {
                Text(err)
                    .foregroundColor(.orange)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("TikTok 9:16 Export")
                    .font(.headline)

                if isTikTokGateEnabled && !monetization.hasPro {
                    Button("Upgrade to Export to TikTok") {
                        isShowingPaywall = true
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)

                    Text("TikTok export is available with Pro.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                } else {
                    PhotosPicker(
                        selection: $selectedVideoItem,
                        matching: .videos,
                        photoLibrary: .shared()
                    ) {
                        Text(isExporting ? "Exporting..." : "Pick Video and Export")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isExporting)
                }

                if AppConfig.FeatureFlags.monetizationEnabled && !monetization.statusMessage.isEmpty {
                    Text(monetization.statusMessage)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Text(exportStatus)
                    .font(.footnote)
                    .foregroundColor(.secondary)

                if let exportOutputURL {
                    Text(exportOutputURL.path)
                        .font(.footnote)
                        .textSelection(.enabled)
                }
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)

            Text("Note: This is ReplayKit-compliant in-app recording.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView()
                .environmentObject(monetization)
        }
        .onChange(of: selectedVideoItem) { newItem in
            guard let item = newItem else { return }

            if isTikTokGateEnabled && !monetization.hasPro {
                exportStatus = "TikTok export requires Pro."
                selectedVideoItem = nil
                isShowingPaywall = true
                return
            }

            Task {
                await exportSelectedVideo(item)
            }
        }
    }

    private func exportSelectedVideo(_ item: PhotosPickerItem) async {
        await MainActor.run {
            exportStatus = "Loading selected video..."
            exportOutputURL = nil
            isExporting = true
        }

        do {
            guard let pickedVideo = try await item.loadTransferable(type: PickedVideo.self) else {
                await MainActor.run {
                    exportStatus = "Unable to load selected video."
                    isExporting = false
                }
                return
            }

            await MainActor.run {
                exportStatus = "Exporting to 1080x1920 MP4..."
            }

            let outputURL = try await TikTokVideoExporter.exportToTikTok(from: pickedVideo.url)

            await MainActor.run {
                exportStatus = "Export complete."
                exportOutputURL = outputURL
                isExporting = false
            }
        } catch {
            await MainActor.run {
                exportStatus = "Export failed: \(error.localizedDescription)"
                isExporting = false
            }
        }
    }
}
