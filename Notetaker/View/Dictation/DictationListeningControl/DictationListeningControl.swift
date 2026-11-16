//
//  DictationListeningControl.swift
//  Notetaker
//
//  Created by Nick Bolton on 11/16/26.
//

import SwiftUI

struct DictationListeningControl: View {
  
  private struct Config {
    static let expandedHeight = 67.0
  }
  
  @Bindable
  private var model: DictationViewModel
  
  init(model: DictationViewModel) {
    self.model = model
  }
  
  var body: some View {
    HStack {
      AudioAmplitudeView(model: model)
      TimeElapsedView(model: model)
      Text("New Note")
      Spacer()
      
      Button {
        model.onStopTapped()
      } label: {
        ZStack {
          
        }
        .frame(maxHeight: .infinity)
        .background(Color.dictationReadyBackground)
        .clipShape(Circle())
      }
    }
    .frame(
      maxWidth: .infinity,
      maxHeight: model.state.isExpanded ? Config.expandedHeight : .infinity
    )
    .clipShape(Capsule())
    .overlay {
      Capsule()
        .strokeBorder(
          model.state.isExpanded ? Color.expandedControlBorder : .clear,
          lineWidth: model.state.isExpanded ? 2.0 : 0.0,
        )
        .animation(.easeInOut, value: model.state.isExpanded)
    }
    .contentShape(Rectangle())
    .onTapGesture {
      model.onStopTapped()
    }
  }
}

#Preview {
  DictationListeningControl(model: DictationViewModel(
    dictationService: LiveDictationService(
      networking: StubbedTranscriptionNetworkService(),
      audioListener: MicrophoneListenerService(),
    ),
  ))
}
