//
//  GeneralResponse.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/13.
//

import Foundation

struct GeneralResponse<T>: Decodable where T: Decodable {
  let statusCode: Int?
  let message: String?
  let data: T?
  
  enum CodingKeys: CodingKey {
    case statusCode
    case message
    case data
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.statusCode = try? container.decodeIfPresent(Int.self, forKey: .statusCode)
    self.message = try? container.decodeIfPresent(String.self, forKey: .message)
    self.data = try? container.decodeIfPresent(T.self, forKey: .data)
  }
}
