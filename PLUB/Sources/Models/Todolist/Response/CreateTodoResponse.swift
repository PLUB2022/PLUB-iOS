//
//  CreateTodoResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/10.
//

import Foundation

struct CreateTodoResponse: Codable {
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
