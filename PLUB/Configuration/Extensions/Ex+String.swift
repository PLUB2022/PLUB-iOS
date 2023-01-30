//
//  ex + String.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/26.
//

extension String {
  
  func fromENGToKOR() -> Self {
    guard let day = Day.allCases.filter({ $0.eng == self }).first else { return "" }
    return day.kor
  }
  
  enum Day: String, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    case all
    
    var kor: String {
      switch self {
      case .monday:
        return "월"
      case .tuesday:
        return "화"
      case .wednesday:
        return "수"
      case .thursday:
        return "목"
      case .friday:
        return "금"
      case .saturday:
        return "토"
      case .sunday:
        return "일"
      case .all:
        return "요일 무관"
      }
    }
    
    var eng: String {
      switch self {
      case .monday: return "MON"
      case .tuesday: return "TUE"
      case .wednesday: return "WED"
      case .thursday: return "THR"
      case .friday: return "FRI"
      case .saturday: return "SAT"
      case .sunday: return "SUN"
      case .all: return "ALL"
      }
     }
  }
}
