//
//  NotetakerView.swift
//  DictationService
//
//  Created by Nick Bolton on 11/16/26.
//

import SwiftUI
import Playgrounds

struct NotetakerView: View {
  
  @Bindable
  private var model: NotetakerViewModel
  
  init(model: NotetakerViewModel) {
    self.model = model
  }
  
  var body: some View {
    ZStack {
      Image("notetaker-bg")
        .resizable()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      
      DictationView(
        model: model.dictationModel,
      )
    }
    .ignoresSafeArea()
  }
}

#Preview {
  NotetakerView(model: NotetakerViewModel())
}
