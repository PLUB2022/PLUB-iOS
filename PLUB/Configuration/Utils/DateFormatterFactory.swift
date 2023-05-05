//
//  DateFormatterFactory.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/15.
//

import Foundation

import Then

enum DateFormatterFactory {
  private static var dateFormatter: DateFormatter {
    DateFormatter().then {
      $0.locale = Locale(identifier: "ko_KR")
    }
  }
  
  /// `yyyy. MM. dd`
  static var dateWithDot: DateFormatter {
    dateFormatter.then { $0.dateFormat = "yyyy. MM. dd" }
  }
  
  /// `yyyy-MM-dd`
  static var dateWithHypen: DateFormatter {
    dateFormatter.then { $0.dateFormat = "yyyy-MM-dd" }
  }
  
  /// `yyyy-MM-dd HH:mm:ss`
  static var dateTime: DateFormatter {
    dateFormatter.then { $0.dateFormat = "yyyy-MM-dd HH:mm:ss" }
  }
  
  /// `yy.MM.dd HH:mm`, 댓글 날짜를 표기하기 위한 DateFormatter
  static var commentDate: DateFormatter {
    dateFormatter.then { $0.dateFormat = "yy.MM.dd HH:mm" }
  }
  
  static var todolistDate: DateFormatter {
    dateFormatter.then { $0.dateFormat = "MM.dd" }
  }
  
  /// `a h시 m분`
  static var koreanTime: DateFormatter {
    dateFormatter.then { $0.dateFormat = "a h시 m분" }
  }
}
