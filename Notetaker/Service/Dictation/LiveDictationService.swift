//
//  LiveDictationService.swift
//  Notetaker
//
//  Created by Nick Bolton on 11/16/26.
//

import Foundation
import AVFoundation

public final class LiveDictationService: DictationService {
  
  private let networking: TranscriptionNetworkService
  private let audioListener: AudioListenerService
  
  public init(
    networking: TranscriptionNetworkService,
    audioListener: AudioListenerService,
  ) {
    self.networking = networking
    self.audioListener = audioListener
  }
  
  public func dictate() -> AsyncThrowingStream<DictationEvent, Error> {
    AsyncThrowingStream { continuation in
      let task = Task {
        do {
          let audio = try audioListener.start()
          let connection = try await networking.connect()

          // Send audio while independently receiving text.
          try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
              // Forward capture immediately; network backpressure must not delay the UI.
              let (pendingAudio, pendingContinuation) =
                AsyncStream<AVReadOnlyAudioPCMBuffer>.makeStream(
                  bufferingPolicy: .bufferingNewest(10)
                )
              try await withThrowingTaskGroup(of: Void.self) { sendGroup in
                sendGroup.addTask {
                  defer { pendingContinuation.finish() }
                  for await buffer in audio {
                    try Task.checkCancellation()
                    continuation.yield(.audioBuffer(buffer))
                    pendingContinuation.yield(buffer)
                  }
                }
                sendGroup.addTask {
                  for await buffer in pendingAudio {
                    try Task.checkCancellation()
                    try await connection.send(buffer)
                  }
                  await connection.close()
                }
                do {
                  try await sendGroup.waitForAll()
                } catch {
                  sendGroup.cancelAll()
                  pendingContinuation.finish()
                  throw error
                }
              }
            }

            group.addTask {
              for try await text in connection.results {
                try Task.checkCancellation()
                continuation.yield(.transcription(text))
              }
            }

            // Propagate failures and cancel the other task.
            do {
              try await group.waitForAll()
            } catch {
              group.cancelAll()
              await connection.close()
              throw error
            }
          }

          continuation.finish()
          try audioListener.stop()
        } catch {
          continuation.finish(throwing: error)
          try audioListener.stop()
        }
      }

      continuation.onTermination = { _ in
        task.cancel()
      }
    }
  }
}
