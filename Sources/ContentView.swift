import SwiftUI
import ReplayKit

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
    @State private var micOn = true

    var body: some View {
        VStack(spacing: 16) {
            Text("Screen Recorder MVP")
                .font(.title2).bold()

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

            Text("Note: This is ReplayKit-compliant in-app recording.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
