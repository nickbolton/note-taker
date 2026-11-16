//
//  DictationService.swift
//  Notetaker
//
//  Created by Nick Bolton on 11/16/26.
//

import Foundation

public protocol DictationService: Sendable {
  func dictate() -> AsyncThrowingStream<String, Error>
}
