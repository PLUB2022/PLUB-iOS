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
  
  static func debug<T>(_ value: T, category: Category, privacy: Privacy = .auto, fileID: String = #fileID, line: Int = #line) {
    let message = String(describing: value)
    switch privacy {
    case .auto:       logger(category: category.rawValue).debug("[\(fileID):\(line)] \(message, privacy: .auto)")
    case .public:     logger(category: category.rawValue).debug("[\(fileID):\(line)] \(message, privacy: .public)")
    case .private:    logger(category: category.rawValue).debug("[\(fileID):\(line)] \(message, privacy: .private)")
    }
  }
  
  static func info<T>(_ value: T, category: Category, privacy: Privacy = .auto, fileID: String = #fileID, line: Int = #line) {
    let message = String(describing: value)
    switch privacy {
    case .auto:       logger(category: category.rawValue).info("[\(fileID):\(line)] \(message, privacy: .auto)")
    case .public:     logger(category: category.rawValue).info("[\(fileID):\(line)] \(message, privacy: .public)")
    case .private:    logger(category: category.rawValue).info("[\(fileID):\(line)] \(message, privacy: .private)")
    }
  }
  
  static func notice<T>(_ value: T, category: Category, privacy: Privacy = .auto, fileID: String = #fileID, line: Int = #line) {
    let message = String(describing: value)
    switch privacy {
    case .auto:       logger(category: category.rawValue).notice("[\(fileID):\(line)] \(message, privacy: .auto)")
    case .public:     logger(category: category.rawValue).notice("[\(fileID):\(line)] \(message, privacy: .public)")
    case .private:    logger(category: category.rawValue).notice("[\(fileID):\(line)] \(message, privacy: .private)")
    }
  }
  
  static func error<T>(_ value: T, category: Category, privacy: Privacy = .auto, fileID: String = #fileID, line: Int = #line) {
    let message = String(describing: value)
    switch privacy {
    case .auto:       logger(category: category.rawValue).error("[\(fileID):\(line)] \(message, privacy: .auto)")
    case .public:     logger(category: category.rawValue).error("[\(fileID):\(line)] \(message, privacy: .public)")
    case .private:    logger(category: category.rawValue).error("[\(fileID):\(line)] \(message, privacy: .private)")
    }
  }
  
  static func fault<T>(_ value: T, category: Category, privacy: Privacy = .auto, fileID: String = #fileID, line: Int = #line) {
    let message = String(describing: value)
    switch privacy {
    case .auto:       logger(category: category.rawValue).fault("[\(fileID):\(line)] \(message, privacy: .auto)")
    case .public:     logger(category: category.rawValue).fault("[\(fileID):\(line)] \(message, privacy: .public)")
    case .private:    logger(category: category.rawValue).fault("[\(fileID):\(line)] \(message, privacy: .private)")
    }
  }
}

// MARK: - Log Enum Cases

extension Log {
  enum Privacy {
    case auto
    case `public`
    case `private`
  }
  
  enum Category: String {
    case network
    case ui
  }
}
