//
//  ex + String.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/26.
//

import Foundation

extension String {
  
  func fromENGToKOR() -> Self {
    guard let day = Day.allCases.filter({ $0.eng == self }).first else { return "" }
    return day.kor
  }
  
  func fromKORToENG() -> Self {
    guard let day = Day.allCases.filter({ $0.kor == self }).first else { return "" }
    return day.eng
  }
}
