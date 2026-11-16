//
//  DictationViewModel.swift
//  MicrophoneService
//
//  Created by Nick Bolton on 11/15/26.
//

import AVFoundation
import Foundation
import SwiftUI
import SwiftUINavigation

@Observable
public final class DictationViewModel: HashableObject, Sendable {
  
  enum State {
    case ready
    case expanded
    case collapsed

    var isExpanded: Bool {
      self == .expanded
    }

    var isReady: Bool {
      self == .ready
    }
  }
  
  @MainActor
  private let dictationService: DictationService
  
  @MainActor
  private let feedback = UIImpactFeedbackGenerator(style: .light)

  @MainActor
  private(set) var state = State.ready
  
  @MainActor
  var isTransitioning = false
  
  struct Translation: Identifiable {
    let id = UUID()
    let text: String
  }

  @MainActor private(set) var translations: [Translation] = []

  @MainActor private(set) var amplitude = 0.0
  @MainActor private(set) var recordingStart: ContinuousClock.Instant?
  @MainActor private(set) var elapsed = 0.0
  @MainActor private var sessionID = UUID()

  @MainActor
  func recordingDuration() -> Double {
    guard let recordingStart else { return elapsed }
    let duration = recordingStart.duration(to: .now).components
    return Double(duration.seconds) + Double(duration.attoseconds) / 1e18
  }

  @MainActor
  private var listenerTask: Task<Void, Error>?
  
  @MainActor
  init(dictationService: DictationService) {
    self.dictationService = dictationService
    feedback.prepare()
    Task {
      await AVAudioApplication.requestRecordPermission()
    }
  }
  
  @MainActor
  var onStopTapped: () -> Void = {}
  
  @MainActor
  func presentListener() {
    guard state.isReady else { return }
    sessionID = UUID()
    let id = sessionID
    translations.removeAll()
    elapsed = 0
    amplitude = 0
    recordingStart = .now
    state = .expanded
    feedback.impactOccurred()
    listenerTask = Task { [dictationService] in
      do {
        for try await event in dictationService.dictate() {
          guard !Task.isCancelled, sessionID == id else { return }
          switch event {
          case .audioBuffer(let buffer): amplitude = Self.amplitude(buffer)
          case .transcription(let text):
            translations.append(Translation(text: text))
          }
        }
      } catch {
        print("An error occurred starting dictation service: \(error)")
      }
      guard sessionID == id else { return }
      elapsed = recordingDuration()
      recordingStart = nil
      amplitude = 0
    }
  }
  
  @MainActor
  func collapseListener() {
    state = .collapsed
    feedback.impactOccurred()
  }
  
  @MainActor
  func reset() {
    sessionID = UUID()
    recordingStart = nil
    translations.removeAll()
    elapsed = 0
    amplitude = 0
    state = .ready
    feedback.impactOccurred()
    
    listenerTask?.cancel()
    listenerTask = nil
  }

  private static func amplitude(_ buffer: AVReadOnlyAudioPCMBuffer) -> Double {
    guard buffer.frameLength > 0 else { return 0 }
    let count = Int(buffer.frameLength)
    let channelCount = Int(buffer.format.channelCount)
    guard channelCount > 0 else { return 0 }
    var energy = 0.0
    for channel in 0..<channelCount {
      switch buffer.channelData(channel) {
      case .float(let samples):
        for frame in 0..<count { let value = Double(samples[frame * buffer.stride]); energy += value * value }
      case .int16(let samples):
        for frame in 0..<count { let value = Double(samples[frame * buffer.stride]) / 32768; energy += value * value }
      case .int32(let samples):
        for frame in 0..<count { let value = Double(samples[frame * buffer.stride]) / 2147483648; energy += value * value }
      @unknown default: return 0
      }
    }
    let rms = sqrt(energy / Double(count * channelCount))
    guard rms.isFinite, rms > 0 else { return 0 }
    return min(1, max(0, (20 * log10(rms) + 60) / 60))
  }
}
