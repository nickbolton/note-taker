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
    state = .expanded
    feedback.impactOccurred()
    listenerTask = Task { [dictationService] in
      do {
        for try await translation in dictationService.dictate() {
          print("\(translation)")
        }
      } catch {
        print("An error occurred starting dictation service: \(error)")
      }
    }
  }
  
  @MainActor
  func collapseListener() {
    state = .collapsed
    feedback.impactOccurred()
  }
  
  @MainActor
  func reset() {
    state = .ready
    feedback.impactOccurred()
    
    listenerTask?.cancel()
    listenerTask = nil
  }
}
