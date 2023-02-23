//
//  BoardsResponse.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/23.
//

import Foundation

struct BoardsResponse: Codable {
  let feedID: Int
  
  enum CodingKeys: String, CodingKey {
    case feedID = "feedId"
  }
}
