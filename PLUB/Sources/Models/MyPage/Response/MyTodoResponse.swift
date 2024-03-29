//
//  MyTodoResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/29.
//

import Foundation

struct MyTodoResponse: Codable {
  let plubbingInfo: PlubbingInfo
  
  let todoInfo: TodoInfo
  
  enum CodingKeys: String, CodingKey {
    case plubbingInfo
    case todoInfo = "todoTimelineResponse"
  }
}

struct TodoInfo: Codable {
  let totalElements: Int
  let isLast: Bool
  let todoContent: [TodoContent]
  
  enum CodingKeys: String, CodingKey {
    case totalElements
    case isLast = "last"
    case todoContent = "content"
  }
}

struct TodoContent: Codable {
  let todoID: Int
  let date: String
  var totalLikes: Int
  let isAuthor: Bool
  var isLike: Bool
  var todoList: [Todo]
  
  enum CodingKeys: String, CodingKey {
    case date, totalLikes, isAuthor, todoList, isLike
    case todoID = "todoTimelineId"
  }
}
