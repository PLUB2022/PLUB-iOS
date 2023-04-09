//
//  Log.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/09.
//

import class Foundation.Bundle
import struct os.Logger

enum Log {
  
  private static let subsystem = Bundle.main.bundleIdentifier!
  
  static private func logger(category: String) -> Logger {
    return .init(subsystem: subsystem, category: category)
  }
}
