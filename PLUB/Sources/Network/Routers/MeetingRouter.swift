//
//  CategoryRouter.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import Alamofire

enum MeetingRouter {
  case createMeeting(CreateMeetingRequest)
  case editMeetingInfo(Int, EditMeetingInfoRequest)
  case inquireCategoryMeeting(String, Int, String, CategoryMeetingRequest?)
  case inquireRecommendationMeeting(Int)
  case inquireMyMeeting(Bool)
}

extension MeetingRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .createMeeting, .inquireCategoryMeeting:
      return .post
    case .editMeetingInfo:
      return .put
    case .inquireRecommendationMeeting, .inquireMyMeeting:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .createMeeting:
      return "/plubbings"
    case .editMeetingInfo(let plubbingId, _):
      return "/plubbings/\(plubbingId)"
    case .inquireCategoryMeeting(let categoryID, _, _, _):
      return "/plubbings/categories/\(categoryID)"
    case .inquireRecommendationMeeting:
      return "/plubbings/recommendation"
    case .inquireMyMeeting:
      return "/plubbings/my"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case let .createMeeting(model):
      return .body(model)
    case let .editMeetingInfo(_, model):
      return .body(model)
    case .inquireCategoryMeeting(_, let cursorID, let sort, let model):
//      guard let model = model else { return .query(["cursorId": cursorID, "sort": sort]) }
      return .queryBody(["cursorId": "\(cursorID)", "sort": sort], model)
    case .inquireRecommendationMeeting(let cursorID):
      return .query(["cursorId": cursorID])
    case .inquireMyMeeting(let isHost):
      return .query(["isHost": isHost])
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .createMeeting, .editMeetingInfo, .inquireCategoryMeeting, .inquireRecommendationMeeting, .inquireMyMeeting:
      return .withAccessToken
    }
  }
}

