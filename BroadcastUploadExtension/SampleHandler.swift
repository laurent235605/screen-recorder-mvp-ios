import ReplayKit

final class SampleHandler: RPBroadcastSampleHandler {
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // TODO: Initialize upload pipeline (file writer or network session).
    }

    override func broadcastPaused() {
        // TODO: Pause ingest/upload work if needed.
    }

    override func broadcastResumed() {
        // TODO: Resume ingest/upload work if needed.
    }

    override func broadcastFinished() {
        // TODO: Flush and finalize pending media data.
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case .video:
            // TODO: Handle video frames.
            break
        case .audioApp:
            // TODO: Handle app audio.
            break
        case .audioMic:
            // TODO: Handle microphone audio.
            break
        @unknown default:
            break
        }
    }
}
