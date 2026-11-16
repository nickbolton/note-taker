//
//  TranscriptionNetworkService.swift
//  Notetaker
//
//  Created by Nick Bolton on 11/16/26.
//

import AVFoundation
import Foundation

public protocol TranscriptionNetworkService: Sendable {
  func connect() async throws -> TranscriptionSession
}
