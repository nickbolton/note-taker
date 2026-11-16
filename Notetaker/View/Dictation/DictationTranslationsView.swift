//
//  DictationTranslationsView.swift
//  Notetaker
//
//  Created by Nick Bolton on 11/16/26.
//

import SwiftUI

struct DictationTranslationsView: View {
  
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  @Bindable
  private var model: DictationViewModel

  init(model: DictationViewModel) {
    self.model = model
  }

  var body: some View {
    Group {
      if model.state.isExpanded {
        ScrollViewReader { proxy in
          ScrollView {
            LazyVStack(alignment: .leading, spacing: 2) {
              ForEach(model.translations) { translation in
                Text(translation.text)
                  .font(.system(size: 16))
                  .foregroundStyle(Color.dictationReadyBackground)
                  .multilineTextAlignment(.leading)
                  .fixedSize(horizontal: false, vertical: true)
                  .padding(.horizontal, 18)
                  .padding(.vertical, 12)
                  .background {
                    UnevenRoundedRectangle(
                      topLeadingRadius: 4,
                      bottomLeadingRadius: 4,
                      bottomTrailingRadius: 18,
                      topTrailingRadius: 18
                    )
                    .fill(Color.dictationTranslationBackground)
                  }
                  .transition(
                    reduceMotion
                      ? .opacity
                      : .offset(y: 8).combined(with: .opacity)
                  )
                  .id(translation.id)
              }
            }
            .animation(
              .easeOut(duration: reduceMotion ? 0.15 : 0.25),
              value: model.translations.last?.id
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 16)
          }
          .allowsHitTesting(false)
          .mask {
            VStack(spacing: 0) {
              LinearGradient(
                colors: [.clear, .black],
                startPoint: .top,
                endPoint: .bottom
              )
              .frame(height: 24)
              Color.black
            }
          }
          .onChange(of: model.translations.last?.id) {
            if let id = model.translations.last?.id {
              proxy.scrollTo(id, anchor: .bottom)
            }
          }
          .onAppear {
            if let id = model.translations.last?.id {
              proxy.scrollTo(id, anchor: .bottom)
            }
          }
        }
      }
    }
    .clipped()
  }
}
