//
//  CategoryRouter.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import Alamofire

enum RecruitmentRouter {
  case inquireDetailRecruitment(String)
  case inquireRecruitmentQuestion(String)
}

extension RecruitmentRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .inquireDetailRecruitment, .inquireRecruitmentQuestion:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireDetailRecruitment(let plubbingId):
      return "/plubbings/\(plubbingId)/recruit"
    case .inquireRecruitmentQuestion(let plubbingId):
      return "/plubbings/\(plubbingId)/recruit/questions"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireDetailRecruitment, .inquireRecruitmentQuestion:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireDetailRecruitment, .inquireRecruitmentQuestion:
      return .withAccessToken
    }
  }
}

