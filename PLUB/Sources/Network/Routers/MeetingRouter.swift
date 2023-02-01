//
//  CategoryRouter.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import Alamofire

enum MeetingRouter {
  case createMeeting(CreateMeetingRequest)
  case inquireCategoryMeeting(String, Int, String)
  case inquireRecommendationMeeting
}

extension MeetingRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .createMeeting:
      return .post
    case .inquireCategoryMeeting, .inquireRecommendationMeeting:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .createMeeting:
      return "/plubbings"
    case .inquireCategoryMeeting(let categoryId, _, _):
      return "/plubbings/categories/\(categoryId)"
    case .inquireRecommendationMeeting:
      return "/plubbings/recommendation"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case let .createMeeting(model):
      return .body(model)
    case .inquireCategoryMeeting(_, let page, let sort):
      return .query(["page": "\(page)", "sort": sort])
    case .inquireRecommendationMeeting:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .createMeeting, .inquireCategoryMeeting, .inquireRecommendationMeeting:
      return .withAccessToken
    }
  }
}

