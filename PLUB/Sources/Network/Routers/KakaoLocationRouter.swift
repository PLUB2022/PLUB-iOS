//
//  KakaoLocationRouter.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/20.
//

import Alamofire

enum KakaoLocationRouter {
  case searchPlace(KakaoLocationRequest)
}

extension KakaoLocationRouter: Router {
  
  var baseURL: String {
    return URLConstants.kakaoLocationUrl
  }
  
  var method: HTTPMethod {
    switch self {
    case .searchPlace:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .searchPlace:
      return "/v2/local/search/keyword.json"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case let .searchPlace(model):
      return .query(model)
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .searchPlace:
      return .withKakaoLocationKey
    }
  }
}
