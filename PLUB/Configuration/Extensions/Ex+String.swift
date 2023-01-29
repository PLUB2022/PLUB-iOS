//
//  ex + String.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/26.
//

extension String {
  
  func fromENGToKOR() -> Self {
    guard let day = Day.allCases.filter({ $0.rawValue == self }).first else { return "" }
    return day.toKOR
  }
  
  enum Day: String, CaseIterable {
    case MON
    case TUE
    case WED
    case THR
    case FRI
    case SAT
    case SUN
    
    var toKOR: String {
      switch self {
      case .MON:
        return "월"
      case .TUE:
        return "화"
      case .WED:
        return "수"
      case .THR:
        return "목"
      case .FRI:
        return "금"
      case .SAT:
        return "토"
      case .SUN:
        return "일"
      }
    }
  }
}
