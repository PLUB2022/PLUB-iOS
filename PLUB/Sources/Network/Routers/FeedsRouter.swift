// 
//  FeedsRouter.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/22.
//

import Alamofire

enum FeedsRouter {
  
}

extension FeedsRouter: Router {
  
  var method: HTTPMethod {
    return .get
  }
  
  var path: String {
    return "/<#Path#>"
  }
  
  var parameters: ParameterType {
    return .plain
  }
  
  var headers: HeaderType {
    return .withAccessToken
  }
}
