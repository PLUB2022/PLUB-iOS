//
//  InquireApplicantResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/15.
//

import Foundation

struct InquireApplicantResponse: Codable {
  let applications: [Application]
  
  enum CodingKeys: String, CodingKey {
    case applications = "appliedAccounts"
  }
}

struct Application: Codable {
  let accountID: Int
  let userName: String
  let profileImage: String?
  let date: String
  let answers: [Answer]
  
  enum CodingKeys: String, CodingKey {
    case accountID = "accountId"
    case userName = "accountName"
    case date = "createdAt"
    case profileImage, answers
  }
}

struct Answer: Codable {
  let question: String
  let answer: String
  
  enum CodingKeys: String, CodingKey {
    case question, answer
  }
}
