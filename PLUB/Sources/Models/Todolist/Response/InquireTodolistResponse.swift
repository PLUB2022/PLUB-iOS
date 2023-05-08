//
//  InquireTodolistResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/04.
//

import Foundation

struct InquireTodolistResponse: Codable {
  let todoTimelineID: Int
  let accountInfo: AccountInfo?
  let totalLikes: Int
  let isAuthor: Bool
  let isLike: Bool
  let todoList: [Todo]
  
  enum CodingKeys: String, CodingKey {
    case todoTimelineID = "todoTimelineId"
    case isLike, totalLikes, isAuthor, accountInfo, todoList
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    todoTimelineID = try values.decodeIfPresent(Int.self, forKey: .todoTimelineID) ?? 0
    isLike = try values.decodeIfPresent(Bool.self, forKey: .isLike) ?? false
    totalLikes = try values.decodeIfPresent(Int.self, forKey: .totalLikes) ?? 0
    isAuthor = try values.decodeIfPresent(Bool.self, forKey: .isAuthor) ?? false
    accountInfo = try values.decodeIfPresent(AccountInfo.self, forKey: .accountInfo)
    todoList = try values.decodeIfPresent([Todo].self, forKey: .todoList) ?? []
  }
}
