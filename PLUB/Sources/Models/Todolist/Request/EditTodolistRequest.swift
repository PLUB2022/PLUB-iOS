//
//  EditTodolistRequest.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/19.
//

import Foundation

struct EditTodolistRequest: Codable {
  let content: String
  let date: String
}
