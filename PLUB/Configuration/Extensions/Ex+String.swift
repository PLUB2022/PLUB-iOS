//
//  ex + String.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/26.
//

extension String {
  
  func fromENGToKOR() -> Self {
    guard let day = Day.allCases.filter({ $0.toKOR == self }).first else { return "" }
    return day.toKOR
  }
}
