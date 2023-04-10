// 
//  ArchiveRouter.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/10.
//

import Alamofire

enum ArchiveRouter {
  
}

extension ArchiveRouter: Router {
  
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
