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
  
  static func debug<T>(_ value: T, category: Category = .default, privacy: Privacy = .auto, fileID: String = #fileID, line: Int = #line, function: String = #function) {
    let message = String(describing: value)
    let fileIDAndLine = "[\(fileID):\(line)]"
    switch privacy {
    case .auto:       logger(category: category.rawValue).debug("\(fileIDAndLine, align: .left(columns: 30)) \(function, align: .left(columns: 50)) \(message, privacy: .auto)")
    case .public:     logger(category: category.rawValue).debug("\(fileIDAndLine, align: .left(columns: 30)) \(function, align: .left(columns: 50)) \(message, privacy: .public)")
    case .private:    logger(category: category.rawValue).debug("\(fileIDAndLine, align: .left(columns: 30)) \(function, align: .left(columns: 50)) \(message, privacy: .private)")
    }
  }
  
  static func info<T>(_ value: T, category: Category = .default, privacy: Privacy = .auto, fileID: String = #fileID, line: Int = #line, function: String = #function) {
    let message = String(describing: value)
    let fileIDAndLine = "[\(fileID):\(line)]"
    switch privacy {
    case .auto:       logger(category: category.rawValue).info("\(fileIDAndLine, align: .left(columns: 30)) \(function, align: .left(columns: 50)) \(message, privacy: .auto)")
    case .public:     logger(category: category.rawValue).info("\(fileIDAndLine, align: .left(columns: 30)) \(function, align: .left(columns: 50)) \(message, privacy: .public)")
    case .private:    logger(category: category.rawValue).info("\(fileIDAndLine, align: .left(columns: 30)) \(function, align: .left(columns: 50)) \(message, privacy: .private)")
    }
  }
  
  static func notice<T>(_ value: T, category: Category = .default, privacy: Privacy = .auto, fileID: String = #fileID, line: Int = #line, function: String = #function) {
    let message = String(describing: value)
    let fileIDAndLine = "[\(fileID):\(line)]"
    switch privacy {
    case .auto:       logger(category: category.rawValue).notice("\(fileIDAndLine, align: .left(columns: 30)) \(function, align: .left(columns: 50)) \(message, privacy: .auto)")
    case .public:     logger(category: category.rawValue).notice("\(fileIDAndLine, align: .left(columns: 30)) \(function, align: .left(columns: 50)) \(message, privacy: .public)")
    case .private:    logger(category: category.rawValue).notice("\(fileIDAndLine, align: .left(columns: 30)) \(function, align: .left(columns: 50)) \(message, privacy: .private)")
    }
  }
  
  static func error<T>(_ value: T, category: Category = .default, privacy: Privacy = .auto, fileID: String = #fileID, line: Int = #line, function: String = #function) {
    let message = String(describing: value)
    let fileIDAndLine = "[\(fileID):\(line)]"
    switch privacy {
    case .auto:       logger(category: category.rawValue).error("\(fileIDAndLine, align: .left(columns: 30)) \(function, align: .left(columns: 50)) \(message, privacy: .auto)")
    case .public:     logger(category: category.rawValue).error("\(fileIDAndLine, align: .left(columns: 30)) \(function, align: .left(columns: 50)) \(message, privacy: .public)")
    case .private:    logger(category: category.rawValue).error("\(fileIDAndLine, align: .left(columns: 30)) \(function, align: .left(columns: 50)) \(message, privacy: .private)")
    }
  }
  
  static func fault<T>(_ value: T, category: Category = .default, privacy: Privacy = .auto, fileID: String = #fileID, line: Int = #line, function: String = #function) {
    let message = String(describing: value)
    let fileIDAndLine = "[\(fileID):\(line)]"
    switch privacy {
    case .auto:       logger(category: category.rawValue).fault("\(fileIDAndLine, align: .left(columns: 30)) \(function, align: .left(columns: 50)) \(message, privacy: .auto)")
    case .public:     logger(category: category.rawValue).fault("\(fileIDAndLine, align: .left(columns: 30)) \(function, align: .left(columns: 50)) \(message, privacy: .public)")
    case .private:    logger(category: category.rawValue).fault("\(fileIDAndLine, align: .left(columns: 30)) \(function, align: .left(columns: 50)) \(message, privacy: .private)")
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
    case `default`
    case network
    case ui
  }
}
