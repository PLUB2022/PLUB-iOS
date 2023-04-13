//
//  MyInfoRequest.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/08.
//

import Foundation

struct MyInfoRequest: Codable {
  let nickname: String
  let introduce: String
  let profileImage: String?
}

extension MyInfoRequest {
  enum CodingKeys: String, CodingKey {
    case nickname, introduce
    case profileImage = "profileImageUrl"
  }
}
