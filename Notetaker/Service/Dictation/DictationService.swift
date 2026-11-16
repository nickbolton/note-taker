//
//  DictationService.swift
//  Notetaker
//
//  Created by Nick Bolton on 11/16/26.
//

import Foundation
import AVFoundation

public enum DictationEvent: Sendable {
  case audioBuffer(AVReadOnlyAudioPCMBuffer)
  case transcription(String)
}

public protocol DictationService: Sendable {
  func dictate() -> AsyncThrowingStream<DictationEvent, Error>
}
