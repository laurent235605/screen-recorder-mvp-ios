import AVFoundation
import Foundation

enum TikTokVideoExportError: LocalizedError {
    case noVideoTrack
    case cannotCreateVideoTrack
    case cannotCreateExportSession
    case exportFailed(String)
    case exportCancelled

    var errorDescription: String? {
        switch self {
        case .noVideoTrack:
            return "No video track was found in the selected file."
        case .cannotCreateVideoTrack:
            return "Unable to prepare the output video track."
        case .cannotCreateExportSession:
            return "Unable to create export session."
        case let .exportFailed(message):
            return "Export failed: \(message)"
        case .exportCancelled:
            return "Export was cancelled."
        }
    }
}

struct TikTokVideoExporter {
    static let outputSize = CGSize(width: 1080, height: 1920)

    static func exportToTikTok(from inputURL: URL) async throws -> URL {
        let asset = AVURLAsset(url: inputURL)
        let duration = try await asset.load(.duration)
        let timeRange = CMTimeRange(start: .zero, duration: duration)

        guard let sourceVideoTrack = try await asset.loadTracks(withMediaType: .video).first else {
            throw TikTokVideoExportError.noVideoTrack
        }

        let composition = AVMutableComposition()
        guard let compositionVideoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw TikTokVideoExportError.cannotCreateVideoTrack
        }

        try compositionVideoTrack.insertTimeRange(timeRange, of: sourceVideoTrack, at: .zero)

        if let sourceAudioTrack = try await asset.loadTracks(withMediaType: .audio).first,
           let compositionAudioTrack = composition.addMutableTrack(
               withMediaType: .audio,
               preferredTrackID: kCMPersistentTrackID_Invalid
           ) {
            try? compositionAudioTrack.insertTimeRange(timeRange, of: sourceAudioTrack, at: .zero)
        }

        let naturalSize = try await sourceVideoTrack.load(.naturalSize)
        let preferredTransform = try await sourceVideoTrack.load(.preferredTransform)
        let orientedRect = CGRect(origin: .zero, size: naturalSize).applying(preferredTransform)
        let sourceSize = CGSize(width: abs(orientedRect.width), height: abs(orientedRect.height))

        let scale = max(
            outputSize.width / sourceSize.width,
            outputSize.height / sourceSize.height
        )
        let scaledSize = CGSize(width: sourceSize.width * scale, height: sourceSize.height * scale)
        let xOffset = (outputSize.width - scaledSize.width) / 2
        let yOffset = (outputSize.height - scaledSize.height) / 2

        // Normalize orientation, then scale-to-fill and center for a 9:16 frame.
        let normalizedTransform = preferredTransform.concatenating(
            CGAffineTransform(translationX: -orientedRect.origin.x, y: -orientedRect.origin.y)
        )
        let finalTransform = normalizedTransform
            .concatenating(CGAffineTransform(scaleX: scale, y: scale))
            .concatenating(CGAffineTransform(translationX: xOffset, y: yOffset))

        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = outputSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = timeRange

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        layerInstruction.setTransform(finalTransform, at: .zero)
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]

        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality
        ) else {
            throw TikTokVideoExportError.cannotCreateExportSession
        }

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tiktok-export-\(UUID().uuidString)")
            .appendingPathExtension("mp4")

        if FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.removeItem(at: outputURL)
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = videoComposition
        exportSession.shouldOptimizeForNetworkUse = true

        try await withCheckedThrowingContinuation { continuation in
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    continuation.resume(returning: ())
                case .cancelled:
                    continuation.resume(throwing: TikTokVideoExportError.exportCancelled)
                case .failed:
                    continuation.resume(
                        throwing: TikTokVideoExportError.exportFailed(
                            exportSession.error?.localizedDescription ?? "Unknown error"
                        )
                    )
                default:
                    continuation.resume(
                        throwing: TikTokVideoExportError.exportFailed("Unexpected export state")
                    )
                }
            }
        }

        return outputURL
    }
}
