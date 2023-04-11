//
//  CreateArchiveResponse.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/10.
//

import Foundation

struct CreateArchiveResponse: Codable {
  let archiveID: Int
  
  enum CodingKeys: String, CodingKey {
    case archiveID = "archiveId"
  }
}
