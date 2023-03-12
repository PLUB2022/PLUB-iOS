//
//  MyInfoResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/12.
//

import Foundation

struct MyInfoResponse: Codable {
  let email: String
  let nickname: String
  let socialType: String
  let birthday: String
  let gender: String
  let introduce: String
  let profileImage: String?
}
