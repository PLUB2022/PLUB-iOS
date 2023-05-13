//
//  InquireTodolistByDateResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/10.
//

import Foundation

struct InquireTodolistByDateResponse: Codable {
  let todoTimelineID: Int
  let date: String
  let totalLikes: Int
  let isAuthor: Bool
  let todoList: [Todo]
  
  enum CodingKeys: String, CodingKey {
    case todoTimelineID = "todoTimelineId"
    case date, totalLikes, isAuthor, todoList
  }
}
