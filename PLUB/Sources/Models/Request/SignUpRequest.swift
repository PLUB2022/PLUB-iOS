//
//  SignUpRequest.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/16.
//

import Foundation

import Then

enum Sex: String, Codable {
  case male = "M"
  case female = "F"
}

struct SignUpRequest: Codable {
  let signToken: String
  let categoryList: [String]
  let profileImage: String
  let birthday: String
  let gender: Sex
  let introduce: String
  let nickname: String
  
  let marketPolicy: Bool
  let personalPolicy: Bool
  let placePolicy: Bool
  let usePolicy: Bool
  let agePolicy: Bool
}
