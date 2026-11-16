//
//  AudioAmplitudeView.swift
//  Notetaker
//
//  Created by Nick Bolton on 11/16/26.
//

import SwiftUI

struct AudioAmplitudeView: View {
  
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  @Bindable
  private var model: DictationViewModel
  
  init(model: DictationViewModel) {
    self.model = model
  }

  var body: some View {
    HStack(spacing: 2) {
      ForEach(0..<3) { index in
        Capsule()
          .frame(width: 3, height: 3 + model.amplitude * (index == 1 ? 14 : 9))
      }
    }
    .frame(width: 12, height: 14)
    .foregroundStyle(model.state.isExpanded ? Color.audioWaveformExpanded : Color.audioWaveformCollapsed)
    .animation(reduceMotion ? nil : .easeInOut(duration: 0.1), value: model.amplitude)
  }
}
