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
  case inquireCategoryMeeting(String, Int, String, CategoryMeetingRequest?)
  case inquireRecommendationMeeting(Int)
}

extension MeetingRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .createMeeting, .inquireCategoryMeeting:
      return .post
    case .editMeetingInfo:
      return .put
    case .inquireRecommendationMeeting:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .createMeeting:
      return "/plubbings"
    case .editMeetingInfo(let plubbingId, _):
      return "/plubbings/\(plubbingId)"
    case .inquireCategoryMeeting(let categoryID, let page, let sort, _):
      return "/plubbings/categories/\(categoryID)?page=\(page)&sort=\(sort)"
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
    case .inquireCategoryMeeting(_, let page, let sort, let model):
      guard let model = model else { return .plain }
      return .body(model)
    case .inquireRecommendationMeeting(let page):
      return .query(["page": page])
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .createMeeting, .editMeetingInfo, .inquireCategoryMeeting, .inquireRecommendationMeeting:
      return .withAccessToken
    }
  }
}

