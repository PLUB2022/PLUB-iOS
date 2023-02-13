//
//  CategoryRouter.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import Alamofire

enum MeetingRouter {
  case createMeeting(CreateMeetingRequest)
  case editMeeting(Int, EditMeetingRequest)
  case inquireCategoryMeeting(String, Int, String)
  case inquireRecommendationMeeting(Int)
}

extension MeetingRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .createMeeting:
      return .post
    case .editMeeting:
      return .put
    case .inquireCategoryMeeting, .inquireRecommendationMeeting:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .createMeeting:
      return "/plubbings"
    case .editMeeting(let plubbingId, _):
      return "/plubbings/\(plubbingId)"
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
    case let .editMeeting(_, model):
      return .body(model)
    case .inquireCategoryMeeting(_, let page, let sort):
      return .query(["page": "\(page)", "sort": sort])
    case .inquireRecommendationMeeting(let page):
      return .query(["page": page])
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .createMeeting, .editMeeting, .inquireCategoryMeeting, .inquireRecommendationMeeting:
      return .withAccessToken
    }
  }
}

