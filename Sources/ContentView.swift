import SwiftUI
import ReplayKit
import PhotosUI
import Photos
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

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
    @State private var exportStatus = "No exported video yet. Pick a video to begin."
    @State private var exportOutputURL: URL?
    @State private var isExporting = false
    @State private var isSavingToPhotos = false
    @State private var isShowingPaywall = false
    @State private var isShowingShareSheet = false
    @State private var activeExportRequestID: UUID?
    private let isTikTokGateEnabled = AppConfig.FeatureFlags.monetizationEnabled
        && AppConfig.FeatureFlags.gateTikTokExportToPro
    private var exportStatusColor: Color {
        let lowered = exportStatus.lowercased()
        if lowered.contains("failed") || lowered.contains("denied") || lowered.contains("already in progress") {
            return .orange
        }
        return .secondary
    }

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
                        Text(isExporting ? "Exporting..." : "Pick Video to Export")
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
                    .foregroundColor(exportStatusColor)

                if let exportOutputURL {
                    Text(exportOutputURL.path)
                        .font(.footnote)
                        .textSelection(.enabled)

                    HStack(spacing: 8) {
                        Button(isSavingToPhotos ? "Saving..." : "Save to Photos") {
                            Analytics.log(.saveToPhotosTapped)
                            Task {
                                await saveExportedVideoToPhotos(exportOutputURL)
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(isSavingToPhotos || isExporting)

                        Button("Share") {
                            if FileManager.default.fileExists(atPath: exportOutputURL.path) {
                                Analytics.log(.shareTapped)
                                isShowingShareSheet = true
                            } else {
                                exportStatus = "Exported file is no longer available. Please export again."
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isExporting)
                    }
                } else {
                    Text("Export output will appear here after a successful conversion.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
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
        .sheet(isPresented: $isShowingShareSheet) {
            if let exportOutputURL {
                ActivityView(activityItems: [exportOutputURL])
            }
        }
        .onChange(of: selectedVideoItem) { newItem in
            guard let item = newItem else { return }

            if isTikTokGateEnabled && !monetization.hasPro {
                exportStatus = "TikTok export requires Pro."
                selectedVideoItem = nil
                isShowingPaywall = true
                return
            }

            guard !isExporting else {
                exportStatus = "An export is already in progress."
                selectedVideoItem = nil
                return
            }

            let requestID = UUID()
            activeExportRequestID = requestID
            isExporting = true
            exportOutputURL = nil
            exportStatus = "Loading selected video..."
            selectedVideoItem = nil

            Task {
                await exportSelectedVideo(item, requestID: requestID)
            }
        }
    }

    private func exportSelectedVideo(_ item: PhotosPickerItem, requestID: UUID) async {
        Analytics.log(.exportStarted)

        do {
            guard let pickedVideo = try await item.loadTransferable(type: PickedVideo.self) else {
                await MainActor.run {
                    if activeExportRequestID == requestID {
                        exportStatus = "Unable to load the selected video. Try another clip."
                        isExporting = false
                        activeExportRequestID = nil
                    }
                }
                Analytics.log(.exportFailed, properties: [
                    "reason": "load_selected_video_failed",
                ])
                return
            }

            await MainActor.run {
                exportStatus = "Exporting to 1080x1920 MP4..."
            }

            let outputURL = try await TikTokVideoExporter.exportToTikTok(from: pickedVideo.url)

            await MainActor.run {
                if activeExportRequestID == requestID {
                    exportStatus = "Export complete. You can save to Photos or share now."
                    exportOutputURL = outputURL
                    isExporting = false
                    activeExportRequestID = nil
                }
            }
            Analytics.log(.exportSuccess)
        } catch {
            await MainActor.run {
                if activeExportRequestID == requestID {
                    exportStatus = "Export failed. \(error.localizedDescription)"
                    isExporting = false
                    activeExportRequestID = nil
                }
            }
            Analytics.log(.exportFailed, properties: [
                "error": error.localizedDescription,
            ])
        }
    }

    private func saveExportedVideoToPhotos(_ url: URL) async {
        guard FileManager.default.fileExists(atPath: url.path) else {
            await MainActor.run {
                exportStatus = "Exported file is no longer available. Please export again."
                isSavingToPhotos = false
            }
            return
        }

        await MainActor.run {
            isSavingToPhotos = true
            exportStatus = "Saving to Photos..."
        }

        let authorizationStatus = await requestPhotoLibraryAddPermission()
        guard authorizationStatus == .authorized || authorizationStatus == .limited else {
            await MainActor.run {
                exportStatus = "Photo access denied. Allow access in Settings to save videos."
                isSavingToPhotos = false
            }
            return
        }

        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }
            await MainActor.run {
                exportStatus = "Saved to Photos."
                isSavingToPhotos = false
            }
        } catch {
            await MainActor.run {
                exportStatus = "Save failed. \(error.localizedDescription)"
                isSavingToPhotos = false
            }
        }
    }

    private func requestPhotoLibraryAddPermission() async -> PHAuthorizationStatus {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                continuation.resume(returning: status)
            }
        }
    }
}
