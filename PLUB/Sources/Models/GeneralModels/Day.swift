//
//  Day.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/10.
//

import Foundation

enum Day: String, Codable, CaseIterable {
  case all       = "ALL"
  case monday    = "MON"
  case tuesday   = "TUE"
  case wednesday = "WED"
  case thursday  = "THR"
  case friday    = "FRI"
  case saturday  = "SAT"
  case sunday    = "SUN"
  
  var kor: String {
    switch self {
    case .monday: return "월"
    case .tuesday: return "화"
    case .wednesday: return "수"
    case .thursday: return "목"
    case .friday: return "금"
    case .saturday: return "토"
    case .sunday: return "일"
    case .all: return "요일 무관"
    }
  }
}
