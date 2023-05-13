//
//  CreateTodoRequest.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/10.
//

import Foundation

struct CreateTodoRequest: Codable {
  let content: String
  let date: String
}
