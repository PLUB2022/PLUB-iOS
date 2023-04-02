//
//  MyApplicationResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/02.
//

import Foundation

struct MyApplicationResponse: Codable {
  let date: String
  let plubbingInfo: PlubbingInfo
  let answers: [Answer]
  enum CodingKeys: String, CodingKey {
    case plubbingInfo, answers
    case date = "recruitDate"
  }
}

struct PlubbingInfo: Codable {
  let plubbingID: Int
  let name: String
  let days: [String]
  let address: String?
  let roadAddress: String?
  let placeName: String?
  let goal: String
  let time: String
  
  enum CodingKeys: String, CodingKey {
    case plubbingID = "plubbingId"
    case name, days, address, roadAddress, placeName, goal, time
  }
}
