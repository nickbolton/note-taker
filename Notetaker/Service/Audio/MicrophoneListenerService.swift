//
//  MicrophoneListenerService.swift
//  Notetaker
//
//  Created by Nick Bolton on 11/16/26.
//

import Foundation
import AVFoundation

public final class MicrophoneListenerService: AudioListenerService {
  
  private let engine = AVAudioEngine()
  private var continuation:
    AsyncStream<AVReadOnlyAudioPCMBuffer>.Continuation?

  public func start() throws -> AsyncStream<AVReadOnlyAudioPCMBuffer> {
    let input = engine.inputNode
    let format = input.outputFormat(forBus: 0)

    let (stream, continuation) =
      AsyncStream<AVReadOnlyAudioPCMBuffer>.makeStream(
        bufferingPolicy: .bufferingNewest(10)
      )

    try input.installAudioTap(
      onBus: 0,
      bufferSize: 4096,
      format: format
    ) { buffer, _ in
      continuation.yield(buffer)
    }

    do {
      engine.prepare()
      try engine.start()
    } catch {
      input.removeTap(onBus: 0)
      continuation.finish()
      throw error
    }

    self.continuation = continuation
    return stream
  }
  
  public func stop() throws {
    engine.stop()
    engine.inputNode.removeTap(onBus: 0)

    continuation?.finish()
    continuation = nil
  }
}
