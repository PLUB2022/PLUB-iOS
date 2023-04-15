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
  
  static var dateWithDot: DateFormatter {
    dateFormatter.then { $0.dateFormat = "yyyy. MM. dd" }
  }
  
  static var dateWithHypen: DateFormatter {
    dateFormatter.then { $0.dateFormat = "yyyy-MM-dd" }
  }
  
}
