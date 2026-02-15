import SwiftUI
import ReplayKit

struct ContentView: View {
    @StateObject private var recorder = ScreenRecorderService()
    @State private var micOn = true

    var body: some View {
        VStack(spacing: 16) {
            Text("Screen Recorder MVP")
                .font(.title2).bold()

            Toggle("Microphone", isOn: $micOn)
                .onChange(of: micOn) { _, newValue in
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
