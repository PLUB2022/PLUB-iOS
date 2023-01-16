//
//  TokenResponse.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/17.
//

import Foundation

struct TokenResponse: Codable {
  
  /// PLUB의 access token
  let accessToken: String
  
  /// PLUB의 refresh token
  let refreshToken: String
}
