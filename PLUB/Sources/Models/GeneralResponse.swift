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
}
