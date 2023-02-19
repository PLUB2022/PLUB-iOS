//
//  Ex+UIResponder.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/19.
//

import UIKit

extension UIResponder {
  private struct StaticResponder {
    static weak var responder: UIResponder?
  }
  
  static func getCurrentResponder() -> UIResponder? {
    StaticResponder.responder = nil
    UIApplication.shared.sendAction(#selector(UIResponder.registerResponder), to: nil, from: nil, for: nil)
    return StaticResponder.responder
  }
  
  @objc
  private func registerResponder() {
    StaticResponder.responder = self
  }
}
