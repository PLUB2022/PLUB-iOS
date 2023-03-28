//
//  InquireAllTodolistResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/28.
//

import Foundation

struct InquireAllTodolistResponse: Codable {
  let todoTimelineID: Int
  let date: String
  let totalLikes: Int
  let isAuthor: Bool
  let accountInfo: AccountInfo
  let todoList: [Todo]
  
  enum CodingKeys: String, CodingKey {
    case todoTimelineID = "todoTimelineId"
    case date, totalLikes, isAuthor, accountInfo, todoList
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

