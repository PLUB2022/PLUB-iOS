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
  
  static func debug<T>(_ value: T, category: String = #fileID, privacy: Privacy = .auto) {
    let message = String(describing: value)
    switch privacy {
    case .auto:
      logger(category: category).debug("\(message, privacy: .auto)")
    case .public:
      logger(category: category).debug("\(message, privacy: .public)")
    case .private:
      logger(category: category).debug("\(message, privacy: .private)")
    }
  }
  
  static func info<T>(_ value: T, category: String = #fileID, privacy: Privacy = .auto) {
    let message = String(describing: value)
    switch privacy {
    case .auto:
      logger(category: category).info("\(message, privacy: .auto)")
    case .public:
      logger(category: category).info("\(message, privacy: .public)")
    case .private:
      logger(category: category).info("\(message, privacy: .private)")
    }
  }
  
  static func notice<T>(_ value: T, category: String = #fileID, privacy: Privacy = .auto) {
    let message = String(describing: value)
    switch privacy {
    case .auto:
      logger(category: category).notice("\(message, privacy: .auto)")
    case .public:
      logger(category: category).notice("\(message, privacy: .public)")
    case .private:
      logger(category: category).notice("\(message, privacy: .private)")
    }
  }
  
  static func error<T>(_ value: T, category: String = #fileID, privacy: Privacy = .auto) {
    let message = String(describing: value)
    switch privacy {
    case .auto:
      logger(category: category).error("\(message, privacy: .auto)")
    case .public:
      logger(category: category).error("\(message, privacy: .public)")
    case .private:
      logger(category: category).error("\(message, privacy: .private)")
    }
  }
  
  static func fault<T>(_ value: T, category: String = #fileID, privacy: Privacy = .auto) {
    let message = String(describing: value)
    switch privacy {
    case .auto:
      logger(category: category).fault("\(message, privacy: .auto)")
    case .public:
      logger(category: category).fault("\(message, privacy: .public)")
    case .private:
      logger(category: category).fault("\(message, privacy: .private)")
    }
  }
}

// MARK: - Log Privacy

extension Log {
  enum Privacy {
    case auto
    case `public`
    case `private`
  }
}
