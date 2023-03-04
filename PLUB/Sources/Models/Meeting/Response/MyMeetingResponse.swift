//
//  MyMeetingResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/01.
//

import Foundation

struct MyMeetingResponse: Codable {
  let myPlubbing: [MyPlubbing]
  
  enum CodingKeys: String, CodingKey {
    case myPlubbing = "plubbings"
  }
}

struct MyPlubbing: Codable {
  let plubbingID: Int
  let name: String
  let goal: String
  let mainImage: String?
  let days: [String]
  
  enum CodingKeys: String, CodingKey {
    case plubbingID = "plubbingId"
    case name, goal, mainImage, days
  }
}
