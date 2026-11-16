//
//  NotetakerViewModel.swift
//  DictationService
//
//  Created by Nick Bolton on 11/16/26.
//

import Foundation
import SwiftUINavigation

@Observable
public final class NotetakerViewModel: HashableObject, Sendable {
  let dictationModel = DictationViewModel(
    dictationService: LiveDictationService(
      networking: StubbedTranscriptionNetworkService(),
      audioListener: MicrophoneListenerService(),
    ),
  )
}
