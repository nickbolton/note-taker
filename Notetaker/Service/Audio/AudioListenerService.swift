//
//  AudioListenerService.swift
//  Notetaker
//
//  Created by Nick Bolton on 11/16/26.
//

import Foundation
import AVFoundation

public protocol AudioListenerService: Sendable {
  func start() throws -> AsyncStream<AVReadOnlyAudioPCMBuffer>
  func stop() throws
}
