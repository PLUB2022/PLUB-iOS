//
//  HeaderType.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/13.
//

import Foundation

import Alamofire

enum HeaderType {
  case `default`
  case withToken
}

extension HeaderType {
  var toHTTPHeader: HTTPHeaders {
    switch self {
    case .default:
      return .default
    //TODO: 승현 - 아직 테스트 코드입니다. UserManager 구현 후 코드가 대체될 예정입니다.
    case .withToken:
      @KeyChainWrapper(key: "accessToken")
      var token: String?
      
      // 토큰이 존재하지 않는 경우
      guard let token = token else { return .default }
      
      // default 헤더 값에 `Authorization token` 및 `Content-Type` 추가
      var defaultHeaders = HTTPHeaders.default
      defaultHeaders.add(.authorization(bearerToken: token))
      defaultHeaders.add(.contentType("application/json"))
      return defaultHeaders
    }
  }
}
