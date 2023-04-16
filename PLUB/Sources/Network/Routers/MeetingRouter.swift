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
  case deleteMeeting(Int)
  case exitMeeting(Int)
  case exportMeetingMember(Int, Int)
  case inquireMeetingMember(Int)
  case endMeeting(Int)
}

extension MeetingRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .createMeeting, .inquireCategoryMeeting:
      return .post
    case .editMeetingInfo, .exitMeeting, .endMeeting:
      return .put
    case .inquireRecommendationMeeting, .inquireMyMeeting, .inquireMeetingMember:
      return .get
    case .deleteMeeting, .exportMeetingMember:
      return .delete
    }
  }
  
  var path: String {
    switch self {
    case .createMeeting:
      return "/plubbings"
    case .editMeetingInfo(let plubbingID, _), .deleteMeeting(let plubbingID):
      return "/plubbings/\(plubbingID)"
    case .inquireCategoryMeeting(let categoryID, _, _, _):
      return "/plubbings/categories/\(categoryID)"
    case .inquireRecommendationMeeting:
      return "/plubbings/recommendation"
    case .inquireMyMeeting:
      return "/plubbings/my"
    case .exitMeeting(let plubbingID):
      return "/api/plubbings/\(plubbingID)/leave"
    case .exportMeetingMember(let plubbingID, let accountID):
      return "/api/plubbings/\(plubbingID)/acoounts/\(accountID)"
    case .inquireMeetingMember(let plubbingID):
      return "/api/plubbings/\(plubbingID)/members"
    case .endMeeting(let plubbingID):
      return "/api/plubbings/\(plubbingID)/status"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case let .createMeeting(model):
      return .body(model)
    case let .editMeetingInfo(_, model):
      return .body(model)
    case .inquireCategoryMeeting(_, let cursorID, let sort, let model):
      return .queryBody(["cursorId": "\(cursorID)", "sort": sort], model)
    case .inquireRecommendationMeeting(let cursorID):
      return .query(["cursorId": cursorID])
    case .inquireMyMeeting(let isHost):
      return .query(["isHost": isHost])
    case .deleteMeeting, .exitMeeting, .exportMeetingMember, .inquireMeetingMember, .endMeeting:
      return .plain
    }
  }
  
  var headers: HeaderType {
    return .withAccessToken
  }
}

