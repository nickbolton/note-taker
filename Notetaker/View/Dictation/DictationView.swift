import SwiftUI

struct DictationView: View {
  
  private struct Config {
    static let dimmerOpacity = 0.15
  }
  
  @Bindable
  private var model: DictationViewModel
  
  init(model: DictationViewModel) {
    self.model = model
    model.onStopTapped = handleStopTapped
  }
  
  var body: some View {
    ZStack {
      // dimmer
      Color.black
        .opacity(model.state.isExpanded ? Config.dimmerOpacity : 0.0)
        .animation(.easeInOut, value: model.state)
        .onTapGesture {
          model.collapseListener()
        }
      
      DictationListeningContainer(
        model: model,
      )
    }
  }
  
  private func handleStopTapped() {
    withAnimation(.defaultSpring) {
      model.reset()
    }
  }
}

#Preview {
  DictationView(
    model: DictationViewModel(
      dictationService: LiveDictationService(
        networking: StubbedTranscriptionNetworkService(),
        audioListener: MicrophoneListenerService(),
      ),
    ),
  )
}
