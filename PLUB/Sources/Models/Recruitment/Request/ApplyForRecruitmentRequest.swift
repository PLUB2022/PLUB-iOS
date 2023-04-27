//
//  ApplyForRecruitmentRequest.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/19.
//

import Foundation

/// 모집 지원 신청을 위한 요청 모델
struct ApplyForRecruitmentRequest: Codable {
  
  /// 응답 리스트
  let answers: [ApplyAnswer]
}

/// 질문에 대한 정보와 응답값을 담고있는 모델
struct ApplyAnswer: Codable, Equatable {
  
  /// 질문 고유 Identifier
  let questionID: Int
  
  /// 질문에 맞춰  작성한 응답값
  let answer: String
  
  enum CodingKeys: String, CodingKey {
    case questionID = "questionId"
    case answer
  }
  
  public static func ==(lhs: ApplyAnswer, rhs: ApplyAnswer) -> Bool{
    return lhs.questionID == rhs.questionID
  }
}
