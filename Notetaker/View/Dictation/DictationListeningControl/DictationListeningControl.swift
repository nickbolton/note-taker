//
//  DictationListeningControl.swift
//  Notetaker
//
//  Created by Nick Bolton on 11/16/26.
//

import SwiftUI

struct DictationListeningControl: View {
  
  private struct Config {
    static let expandedHeight = 62.0
  }
  
  @Bindable
  private var model: DictationViewModel
  
  @MainActor
  private var nameColor: Color {
    model.state.isExpanded ? Color.dictationReadyBackground : .white
  }
  
  @MainActor
  private var stopButtonBackground: Color {
    model.state.isExpanded ? Color.dictationReadyBackground : .white
  }
  
  @MainActor
  private var stopButtonIconColor: Color {
    model.state.isExpanded ? .white : Color.dictationReadyBackground
  }
  
  @MainActor
  private var stopButtonFontSize: Double {
    model.state.isExpanded ? 17.0 : 14.0
  }
  
  init(model: DictationViewModel) {
    self.model = model
  }
  
  var body: some View {
    HStack {
      AudioAmplitudeView(model: model)
        .padding(.leading)
      
      TimeElapsedView(model: model)
      
      Text("New Note" )
        .font(.system(size: 14.0, weight: .semibold))
        .foregroundStyle(nameColor)
      
      Spacer()
      
      Button {
        model.onStopTapped()
      } label: {
        ZStack {
          stopButtonBackground
          Image(systemName: "stop.fill")
            .font(.system(size: stopButtonFontSize))
            .foregroundStyle(stopButtonIconColor)
        }
        .frame(maxHeight: .infinity)
        .aspectRatio(1.0, contentMode: .fit)
        .clipShape(Circle())
        .padding(.trailing, model.state.isExpanded ? 4.0 : 3.0)
        .padding(.vertical, model.state.isExpanded ? 4.5 : 3.5)
      }
    }
    .frame(
      maxWidth: .infinity,
      maxHeight: model.state.isExpanded ? Config.expandedHeight : .infinity,
    )
    .clipShape(Capsule())
    .overlay {
      Capsule()
        .strokeBorder(
          model.state.isExpanded ? Color.expandedControlBorder : .clear,
          lineWidth: model.state.isExpanded ? 2.0 : 0.0,
        )
    }
    .opacity(model.isTransitioning ? 0.0 : 1.0)
    .transaction { transaction in
      transaction.animation = nil
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
