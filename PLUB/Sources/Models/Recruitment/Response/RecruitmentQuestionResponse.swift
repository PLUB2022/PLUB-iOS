//
//  RecruitmentQuestionResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/23.
//

import Foundation

/// 플러빙 모집 글의 질문 조회 응답 모델
struct RecruitmentQuestionResponse: Codable {
  
  /// 질문 리스트
  let questions: [Question]
  
  enum CodingKeys: String, CodingKey {
    case questions
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    questions = try values.decodeIfPresent([Question].self, forKey: .questions) ?? []
  }
}

/// 질문 정보 모델
struct Question: Codable {
  
  /// 질문 글의 고유 ID
  let id: Int
  
  /// 질문글
  let question: String
}

