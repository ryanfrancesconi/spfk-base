// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import AVFAudio

/// A sequential source of decoded PCM, for audio `AVAudioFile` cannot open.
///
/// Exists for containers outside AVFoundation's set — Matroska is the one users hit, where
/// `AVAudioFile(forReading:)` throws `'fmt?'` and no amount of retrying helps. A demuxer plus a
/// decoder can produce the samples; this is the shape a front-to-back consumer needs them in.
///
/// **Sequential only, with no seek.** That keeps a conforming type free to stream, so a two-hour
/// film's audio never has to exist in memory at once.
public protocol SequentialPCMSource: AnyObject {
    /// The format samples arrive in. Must be a PCM format with float channel data.
    var processingFormat: AVAudioFormat { get }

    /// Total frames in the source, or 0 when it cannot be known before reading.
    var totalFrameCount: AVAudioFramePosition { get }

    /// Fills `buffer` with up to `frameCount` frames and returns how many were written. Returns 0
    /// once the source is exhausted; a short read that is not 0 does not mean the end.
    func readNextChunk(into buffer: AVAudioPCMBuffer, frameCount: AVAudioFrameCount) throws -> AVAudioFrameCount
}
