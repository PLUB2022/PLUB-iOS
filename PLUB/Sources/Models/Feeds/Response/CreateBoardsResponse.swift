//
//  CreateBoardsResponse.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/23.
//

import Foundation

struct CreateBoardsResponse: Codable {
  let data: Content
}

extension CreateBoardsResponse {
  struct Content: Codable {
    let feedID: Int
    
    enum CodingKeys: String, CodingKey {
      case feedID = "feedId"
    }
  }
}
