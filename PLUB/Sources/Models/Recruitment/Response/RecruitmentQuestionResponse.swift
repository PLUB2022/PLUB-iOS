//
//  RecruitmentQuestionResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/23.
//

import Foundation

struct RecruitmentQuestionResponse: Codable {
  let questions: [Question]
  
  enum CodingKeys: String, CodingKey {
    case questions
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    questions = try values.decodeIfPresent([Question].self, forKey: .questions) ?? []
  }
}

struct Question: Codable {
  let id: Int
  let question: String
}

