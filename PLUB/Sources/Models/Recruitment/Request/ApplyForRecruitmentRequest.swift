//
//  ApplyForRecruitmentRequest.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/19.
//

import Foundation

struct ApplyForRecruitmentRequest: Codable {
  let answers: [ApplyAnswer]
}

struct ApplyAnswer: Codable, Equatable {
  let questionID: Int
  let answer: String
  
  enum CodingKeys: String, CodingKey {
    case questionID = "questionId"
    case answer
  }
  
}