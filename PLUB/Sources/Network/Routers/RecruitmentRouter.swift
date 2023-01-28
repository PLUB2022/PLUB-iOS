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
  case searchRecruitment(SearchParameter)
}

extension RecruitmentRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .inquireDetailRecruitment, .inquireRecruitmentQuestion, .searchRecruitment:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireDetailRecruitment(let plubbingId):
      return "/plubbings/\(plubbingId)/recruit"
    case .inquireRecruitmentQuestion(let plubbingId):
      return "/plubbings/\(plubbingId)/recruit/questions"
    case .searchRecruitment:
      return "/plubbings/recruit"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireDetailRecruitment, .inquireRecruitmentQuestion:
      return .plain
    case .searchRecruitment(let parameter):
      return .query(parameter)
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireDetailRecruitment, .inquireRecruitmentQuestion, .searchRecruitment:
      return .withAccessToken
    }
  }
}


