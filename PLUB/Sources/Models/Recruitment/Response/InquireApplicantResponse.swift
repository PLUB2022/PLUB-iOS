//
//  InquireApplicantResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/15.
//

import Foundation

/// 지원자 전체 조회 응답 모델
struct InquireApplicantResponse: Codable {
  
  /// 지원서 리스트
  let applications: [Application]
  
  enum CodingKeys: String, CodingKey {
    case applications = "appliedAccounts"
  }
}

/// 지원서 모델
struct Application: Codable {
  
  /// 계정 ID
  let accountID: Int
  
  /// 사용자 이름
  let userName: String
  
  /// 사용자의 프로필 이미지
  let profileImage: String?
  
  /// 지원 날짜
  ///
  /// `yyyy-MM-dd hh:mm:ss`형태로 값을 내려받습니다.
  let date: String
  
  /// 응답 리스트
  let answers: [Answer]
  
  enum CodingKeys: String, CodingKey {
    case accountID = "accountId"
    case userName = "accountName"
    case date = "createdAt"
    case profileImage, answers
  }
}

/// 질문과 응답을 포함한 모델
struct Answer: Codable {
  
  /// 질문글
  let question: String
  
  /// 응답글
  let answer: String
  
  enum CodingKeys: String, CodingKey {
    case question, answer
  }
}
