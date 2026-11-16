//
//  DictationReadyView.swift
//  Notetaker
//
//  Created by Nick Bolton on 11/16/26.
//

import SwiftUI

struct DictationReadyView: View {
  
  struct Config {
    static let size = 61.0
    static let outerRingSize = 23.0
    static let dotBackgroundSize = 16.0
    static let dotSize = 10.0
    static let pressedOpacity = 0.7
  }
  
  @Bindable
  private var model: DictationViewModel
  
  @GestureState
  private var isDragging = false
  
  @State
  private var isReadyArmed = false

  init(model: DictationViewModel) {
    self.model = model
  }
  
  var body: some View {
    ZStack {
      
      // outer ring
      Color.white
        .frame(
          width: Config.outerRingSize,
          height: Config.outerRingSize,
        )
        .clipShape(
          Circle()
        )
        .overlay {
          Circle()
            .strokeBorder(Color.black, lineWidth: .onePixel)
        }
        .opacity(isReadyArmed ? Config.pressedOpacity : 1.0)
        .animation(.easeInOut, value: isReadyArmed)

      // dot background
      Color.dictationReadyBackground
        .frame(
          width: Config.dotBackgroundSize,
          height: Config.dotBackgroundSize,
        )
        .clipShape(Circle())

      // dot
      Color.white
        .frame(
          width: Config.dotSize,
          height: Config.dotSize,
        )
        .clipShape(Circle())
        .overlay {
          Circle()
            .strokeBorder(Color.black, lineWidth: .onePixel)
        }
        .opacity(isReadyArmed ? Config.pressedOpacity : 1.0)
        .animation(.easeInOut, value: isReadyArmed)
    }
    .frame(
      maxWidth: .infinity,
      maxHeight: .infinity,
    )
    .gesture(
      DragGesture(minimumDistance: 0.0)
        .updating( $isDragging, body: { value, state, _ in
          state = true
          isReadyArmed = CGRect(
            origin: .zero,
            size: CGSize(
              width: Config.size,
              height: Config.size
            )
          ).contains(value.location)
        })
        .onEnded { _ in
          if isReadyArmed {
            model.presentListener()
          }
          isReadyArmed = false
        }
    )
  }
}

#Preview {
  DictationReadyView(model: DictationViewModel(
    dictationService: LiveDictationService(
      networking: StubbedTranscriptionNetworkService(),
      audioListener: MicrophoneListenerService(),
    ),
  ))
}
