//
//  DictationListeningContainer.swift
//  Notetaker
//
//  Created by Nick Bolton on 11/16/26.
//

import SwiftUI

struct DictationListeningContainer: View {
  
  private struct Config {
    static let sideMargins = 20.0
    static let defaultBottomPadding = 90.0
    
    // ready
    static let readySize = DictationReadyView.Config.size
    static let readyCornerRadius = readySize / 2.0
    
    // expanded
    static let expandedCornerRadius = 20.0
    static let expandedHeight = 362.0
    static let expandedControlSidePadding = 16.0
    static let expandedControlBottomPadding = 32.0
    static let expandedBottomPadding = 16.0

    // collapsed
    static let collapsedHeight = 50.0
  }
  
  @Bindable
  private var model: DictationViewModel
  
  @State
  private var height = 0.0
  
  @State
  private var cornerRadius = 0.0
  
  @State
  private var maxWidth = 0.0
  
  @State
  private var bottomPadding = 0.0
  
  @State
  private var readyOpacity = 1.0

  @State
  private var listenerBackgroundOpacity = 0.0

  @State
  private var listenerOpacity = 0.0

  init(model: DictationViewModel) {
    self.model = model
  }
  
  var body: some View {
    ZStack {
      VStack {
        Spacer()
    
        DictationReadyView(
          model: model,
        )
        .frame(
          width: Config.readySize,
          height: Config.readySize,
        )
        .background {
          Color.dictationReadyBackground
        }
        .clipShape(Circle())
        .overlay {
          Circle()
            .strokeBorder(
              Color.expandedListenerContainerBorder,
              lineWidth: .onePixel,
            )
        }
        .opacity(readyOpacity)
        .padding(.bottom, Config.defaultBottomPadding)
      }

      VStack {
        Spacer()
        VStack {
          DictationTranslationsView(
            model: model,
          )
          .frame(
            maxWidth: .infinity,
            maxHeight: model.state.isExpanded ? .infinity : 0.0,
          )
          
          DictationListeningControl(
            model: model,
          )
          .padding(.horizontal, model.state.isExpanded ? Config.expandedControlSidePadding : 0.0)
          .padding(.bottom, model.state.isExpanded ? Config.expandedControlBottomPadding : 0.0)
          .animation(.defaultSpring, value: model.state.isExpanded)
        }
        .frame(maxWidth: maxWidth)
        .frame(height: height)
        .background {
          Group {
            Color.white
              .opacity(listenerBackgroundOpacity)
            Color.dictationReadyBackground
              .opacity(model.state.isExpanded ? 0.0 : listenerBackgroundOpacity)
              .animation(.defaultSpring, value: model.state.isExpanded)
          }
        }
        .cornerRadius(cornerRadius)
        .overlay {
          RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(
              Color.expandedListenerContainerBorder,
              lineWidth: .onePixel,
            )
            .opacity(model.state.isReady ? 0.0 : 1.0)
        }
        .shadow(
          color: .black.opacity(!model.state.isReady ? 0.3 : 0.0),
          radius: 18,
          y: 6,
        )
        .padding(.horizontal, Config.sideMargins)
        .padding(.bottom, bottomPadding)
        .animation(.defaultSpring, value: model.state.isExpanded)
        .animation(.defaultSpring, value: bottomPadding)
      }
      .opacity(listenerOpacity)
      .allowsHitTesting(!model.state.isReady)
    }
    .onChange(of: model.state) { oldValue, newValue in
      switch (oldValue, newValue) {
      case (.expanded, .collapsed):
        withAnimation(.defaultSpring) {
          setCollapsedState()
        }
      case (.ready, .expanded):
        model.isTransitioning = true
        listenerBackgroundOpacity = 1.0
        listenerOpacity = 1.0
        withAnimation(.defaultSpring) {
          setExpandedState()
        } completion: {
          readyOpacity = 0.0
        }
      case (.collapsed, .ready), (.expanded, .ready):
        model.isTransitioning = true
        withAnimation(.defaultSpring) {
          setReadyState()
        } completion: {
          readyOpacity = 1.0
          listenerBackgroundOpacity = 0.0
          listenerOpacity = 0.0
        }
      default: ()
      }
    }
    .onAppear {
      setReadyState()
    }
  }
  
  private func setReadyState() {
    height = Config.readySize
    cornerRadius = Config.readyCornerRadius
    maxWidth = Config.readySize
    bottomPadding = Config.defaultBottomPadding
    model.isTransitioning = false
  }
  
  private func setExpandedState() {
    maxWidth = .infinity
    height = Config.expandedHeight
    cornerRadius = Config.expandedCornerRadius
    bottomPadding = Config.expandedBottomPadding
    model.isTransitioning = false
  }
  
  private func setCollapsedState() {
    height = Config.collapsedHeight
    cornerRadius = height / 2.0
    bottomPadding = Config.defaultBottomPadding
    model.isTransitioning = false
  }
}

#Preview {
  DictationListeningContainer(model: DictationViewModel(
    dictationService: LiveDictationService(
      networking: StubbedTranscriptionNetworkService(),
      audioListener: MicrophoneListenerService(),
    ),
  ))
}
