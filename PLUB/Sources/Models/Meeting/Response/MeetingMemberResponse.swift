//
//  MeetingMemberResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/17.
//

import Foundation

struct MeetingMemberResponse: Codable {
  let accounts: [AccountInfo]
  
  enum CodingKeys: String, CodingKey {
    case accounts = "accountInfo"
  }
}
