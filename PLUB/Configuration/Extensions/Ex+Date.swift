//
//  Ex+Date.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/14.
//

import Foundation

extension Date {
  func toString() -> String {
    let formatter = DateFormatter()
    return formatter.string(from: self)
  }
}
