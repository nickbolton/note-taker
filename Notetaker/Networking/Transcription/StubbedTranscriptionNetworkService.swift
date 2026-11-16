//
//  StubbedTranscriptionNetworkService.swift
//  Notetaker
//
//  Created by Nick Bolton on 11/16/26.
//

import AVFoundation
import Foundation

public final class StubbedTranscriptionNetworkService: TranscriptionNetworkService {
  public func connect() async throws -> TranscriptionSession {
    TranscriptionSession()
  }
}

public actor TranscriptionSession {
  let results: AsyncThrowingStream<String, Error>

  private let continuation:
    AsyncThrowingStream<String, Error>.Continuation

  init() {
    (results, continuation) =
      AsyncThrowingStream<String, Error>.makeStream()
  }

  private let words = [
    "lorem", "ipsum", "dolor", "sit", "amet",
    "consectetur", "adipiscing", "elit", "sed",
    "do", "eiusmod", "tempor", "incididunt",
    "ut", "labore", "et", "dolore", "magna",
    "aliqua", "enim", "ad", "minim", "veniam",
    "quis", "nostrud", "exercitation", "ullamco",
    "laboris", "nisi", "aliquip", "commodo",
    "consequat"
  ]

  func send(_ buffer: AVReadOnlyAudioPCMBuffer) async throws {
    let count = Int.random(in: 3...10)

    let text = (0..<count)
      .compactMap { _ in words.randomElement() }
      .joined(separator: " ")

    try await Task.sleep(
      for: .seconds(
        Int.random(in: 2...6)
      )
    )
    continuation.yield(text)
  }
  
  func close() {
    continuation.finish()
  }
}
