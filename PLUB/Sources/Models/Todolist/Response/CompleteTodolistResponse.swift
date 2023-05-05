//
//  CompleteTodolistResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/04.
//

import Foundation

struct CompleteProofTodolistResponse: Codable {
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
