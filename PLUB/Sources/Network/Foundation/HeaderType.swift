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
  case withAccessToken
  case withRefreshToken
  case withKakaoLocationKey
  case formData
}

extension HeaderType {
  var toHTTPHeader: HTTPHeaders {
    switch self {
    case .default:
      var defaultHeaders = HTTPHeaders.default
      defaultHeaders.add(.contentType("application/json"))
      return defaultHeaders
    case .withAccessToken:
      // 토큰이 존재하지 않는 경우 default 리턴
      guard let token = UserManager.shared.accessToken else {
        return HeaderType.default.toHTTPHeader
      }
      
      // default 헤더 값에 `Authorization token` 및 `Content-Type` 추가
      var defaultHeaders = HTTPHeaders.default
      defaultHeaders.add(.authorization(bearerToken: token))
      defaultHeaders.add(.contentType("application/json"))
      return defaultHeaders
      
    case .withRefreshToken:
      // 토큰이 존재하지 않는 경우 default 리턴
      guard let token = UserManager.shared.refreshToken else {
        return HeaderType.default.toHTTPHeader
      }
      
      // default 헤더 값에 `Authorization token` 및 `Content-Type` 추가
      var defaultHeaders = HTTPHeaders.default
      defaultHeaders.add(.authorization(bearerToken: token))
      defaultHeaders.add(.contentType("application/json"))
      return defaultHeaders
      
    case .withKakaoLocationKey:
      // default 헤더 값에 `Authorization kakaoLocationKey 추가`
      var defaultHeaders = HTTPHeaders.default
      defaultHeaders.add(.authorization(KeyConstants.kakaoLocationKey))
      return defaultHeaders
      
    case .formData:
      // default 헤더 값에 `multipart/form-data` 추가
      var defaultHeaders = HTTPHeaders.default
      defaultHeaders.add(.contentType("multipart/form-data"))
      
      // 토큰이 존재하지 않는 경우 default 리턴
      guard let token = UserManager.shared.accessToken else {
        return defaultHeaders
      }
      
      // 토큰이 존재하는 경우 `Authorization token` 추가
      defaultHeaders.add(.authorization(bearerToken: token))
      return defaultHeaders
    }
  }
}
