//
//  LiveDictationService.swift
//  Notetaker
//
//  Created by Nick Bolton on 11/16/26.
//

import Foundation

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
  
  public func dictate() -> AsyncThrowingStream<String, Error> {
    AsyncThrowingStream { continuation in
      let task = Task {
        do {
          let audio = try audioListener.start()
          let connection = try await networking.connect()

          // Send audio while independently receiving text.
          try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
              for await buffer in audio {
                try Task.checkCancellation()
                try await connection.send(buffer)
              }

              await connection.close()
            }

            group.addTask {
              for try await text in connection.results {
                try Task.checkCancellation()
                continuation.yield(text)
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
