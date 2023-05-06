//
//  LikeTodolistResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/05.
//

import Foundation

struct LikeTodolistResponse: Codable {
  
  /// 투두리스트에 해당하는 타임라인 아이디
  let todoTimelineID: Int
  
  /// 해당 투두리스트가 작성된 일자
  let date: String
  
  /// 해당 투두리스트의 좋아요 수
  let totalLikes: Int
  
  /// 해당 투두리스트의 작성자인지에 대한 여부
  let isAuthor: Bool
  
  /// 해당 투두리스트를 내가 좋아요 눌렀는지에 대한 여부
  let isLike: Bool
  
  /// 해당 투두리스트의 존재하는 투두
  let todoList: [Todo]
  
  enum CodingKeys: String, CodingKey {
    case todoTimelineID = "todoTimelineId"
    case date, totalLikes, isAuthor, isLike, todoList
  }
}
