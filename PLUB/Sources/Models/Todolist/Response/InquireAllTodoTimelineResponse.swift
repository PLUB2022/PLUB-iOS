//
//  InquireAllTodolistResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/28.
//

import Foundation

struct InquireAllTodoTimelineResponse: Codable {
  let todoTimelineID: Int
  let date: String
  let totalLikes: Int
  let isAuthor: Bool
  let isLike: Bool
  let accountInfo: AccountInfo?
  let todoList: [Todo]
  
  enum CodingKeys: String, CodingKey {
    case todoTimelineID = "todoTimelineId"
    case date, totalLikes, isAuthor, isLike, accountInfo, todoList
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    todoTimelineID = try values.decodeIfPresent(Int.self, forKey: .todoTimelineID) ?? 0
    date = try values.decodeIfPresent(String.self, forKey: .date) ?? ""
    totalLikes = try values.decodeIfPresent(Int.self, forKey: .totalLikes) ?? 0
    isAuthor = try values.decodeIfPresent(Bool.self, forKey: .isAuthor) ?? false
    isLike = try values.decodeIfPresent(Bool.self, forKey: .isLike) ?? false
    accountInfo = try values.decodeIfPresent(AccountInfo.self, forKey: .accountInfo)
    todoList = try values.decodeIfPresent([Todo].self, forKey: .todoList) ?? []
  }
}

struct Todo: Codable {
  let todoID: Int
  let content: String
  let date: String
  let isChecked: Bool
  let isProof: Bool
  let proofImage: String
  let isAuthor: Bool
  
  enum CodingKeys: String, CodingKey {
    case todoID = "todoId"
    case content, date, isChecked, isProof, proofImage, isAuthor
  }
}

