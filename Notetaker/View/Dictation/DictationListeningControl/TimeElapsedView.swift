//
//  TimeElapsedView.swift
//  Notetaker
//
//  Created by Nick Bolton on 11/16/26.
//

import SwiftUI

struct TimeElapsedView: View {
  
  @Bindable
  private var model: DictationViewModel
  
  init(model: DictationViewModel) {
    self.model = model
  }

  var body: some View {
    TimelineView(.periodic(from: .now, by: 1)) { _ in
      let seconds = Int(max(0, model.recordingDuration()))
      Text("\(seconds / 60):" + String(format: "%02d", seconds % 60))
        .font(.system(size: 14.0, weight: .semibold, design: .rounded))
        .monospacedDigit()
        .foregroundStyle(model.state.isExpanded ? Color.audioWaveformExpanded : Color.audioWaveformCollapsed)
        .accessibilityLabel("Recording duration")
    }
  }
}
