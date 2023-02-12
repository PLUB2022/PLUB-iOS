//
//  CategoryRouter.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import Alamofire

enum MeetingRouter {
  case createMeeting(CreateMeetingRequest)
  case editMeetingInfo(String, EditMeetingInfoRequest)
  case inquireCategoryMeeting(String, Int, String)
  case inquireRecommendationMeeting
}

extension MeetingRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .createMeeting:
      return .post
    case .editMeetingInfo:
      return .put
    case .inquireCategoryMeeting, .inquireRecommendationMeeting:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .createMeeting:
      return "/plubbings"
    case .editMeetingInfo(let plubbingId, _):
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
    case let .editMeetingInfo(_, model):
      return .body(model)
    case .inquireCategoryMeeting(_, let page, let sort):
      return .query(["page": "\(page)", "sort": sort])
    case .inquireRecommendationMeeting:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .createMeeting, .editMeetingInfo, .inquireCategoryMeeting, .inquireRecommendationMeeting:
      return .withAccessToken
    }
  }
}

