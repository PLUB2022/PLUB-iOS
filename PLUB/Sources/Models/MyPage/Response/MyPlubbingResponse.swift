//
//  MyPlubbingResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/13.
//

import Foundation

enum PlubbingStatusType: String, CaseIterable {
  case recruiting = "RECRUITING"
  case waiting = "WAITING"
  case active = "ACTIVE"
  case end = "END"
}

struct MyPlubbingResponse: Codable {
  let plubbingStatus: PlubbingStatusType.RawValue
  let plubbings: [MyPagePlubbing]
  
  enum CodingKeys: String, CodingKey {
    case plubbingStatus
    case plubbings
  }
}

struct MyPagePlubbing: Codable {
  let plubbingID: Int
  let name: String
  let goal: String
  let iconImage: String
  let myPlubbingStatus: String
  
  enum CodingKeys: String, CodingKey {
    case plubbingID = "plubbingId"
    case name = "title"
    case goal, iconImage, myPlubbingStatus
  }
}
