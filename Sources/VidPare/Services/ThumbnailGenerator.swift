import AppKit
import AVFoundation

final class ThumbnailGenerator {
    private let asset: AVURLAsset
    private var generator: AVAssetImageGenerator

    init(asset: AVURLAsset) {
        self.asset = asset
        self.generator = AVAssetImageGenerator(asset: asset)
        self.generator.appliesPreferredTrackTransform = true
        self.generator.maximumSize = CGSize(width: 160, height: 90)
        self.generator.requestedTimeToleranceBefore = .zero
        self.generator.requestedTimeToleranceAfter = CMTime(seconds: 0.1, preferredTimescale: 600)
    }

    func generateThumbnails(count: Int) async throws -> [NSImage] {
        let duration = try await asset.load(.duration)
        let totalSeconds = CMTimeGetSeconds(duration)
        guard totalSeconds > 0 else { return [] }

        let clampedCount = max(10, min(count, 60))
        let interval = totalSeconds / Double(clampedCount)

        let requestedTimes: [NSValue] = (0..<clampedCount).map { index in
            let requestTime = CMTime(seconds: Double(index) * interval, preferredTimescale: 600)
            return NSValue(time: requestTime)
        }

        return try await withCheckedThrowingContinuation { continuation in
            var images: [Int: NSImage] = [:]
            var completedCount = 0
            let expectedCount = requestedTimes.count
            let stateQueue = DispatchQueue(label: "VidPare.ThumbnailGenerator.State")

            generator.generateCGImagesAsynchronously(forTimes: requestedTimes) { requestedTime, cgImage, _, result, _ in
                var finishedImages: [NSImage]?
                stateQueue.sync {
                    if let cgImage = cgImage, result == .succeeded {
                        let requestedSeconds = CMTimeGetSeconds(requestedTime)
                        let rawIndex = interval > 0 ? Int((requestedSeconds / interval).rounded()) : 0
                        let index = min(max(rawIndex, 0), expectedCount - 1)
                        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
                        images[index] = nsImage
                    }

                    completedCount += 1
                    if completedCount == expectedCount {
                        finishedImages = (0..<expectedCount).compactMap { images[$0] }
                    }
                }
                if let finishedImages {
                    continuation.resume(returning: finishedImages)
                }
            }
        }
    }

    func cancelGeneration() {
        generator.cancelAllCGImageGeneration()
    }

    static func thumbnailCount(forDuration seconds: Double) -> Int {
        // ~1 thumbnail per 2 seconds, clamped between 10 and 60
        let count = Int(seconds / 2.0)
        return max(10, min(count, 60))
    }
}
