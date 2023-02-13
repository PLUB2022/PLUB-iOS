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
  case requestBookmark(String)
  case editMeetingPost(String, EditMeetingPostRequest)
  case editMeetingQuestion(String, EditMeetingQuestionRequest)
}

extension RecruitmentRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .inquireDetailRecruitment, .inquireRecruitmentQuestion, .searchRecruitment:
      return .get
    case .requestBookmark:
      return .post
    case .editMeetingPost, .editMeetingQuestion:
      return .put
    }
  }
  
  var path: String {
    switch self {
    case .inquireDetailRecruitment(let plubbingID):
      return "/plubbings/\(plubbingID)/recruit"
    case .inquireRecruitmentQuestion(let plubbingID):
      return "/plubbings/\(plubbingID)/recruit/questions"
    case .searchRecruitment:
      return "/plubbings/recruit"
    case .requestBookmark(let plubbingID):
      return "/plubbings/\(plubbingID)/recruit/bookmarks"
    case .editMeetingPost(let plubbingID, _):
      return "/plubbings/\(plubbingID)/recruit"
    case .editMeetingQuestion(let plubbingID, _):
      return "/plubbings/\(plubbingID)/recruit/questions"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireDetailRecruitment, .inquireRecruitmentQuestion, .requestBookmark:
      return .plain
    case .searchRecruitment(let parameter):
      return .query(parameter)
    case .editMeetingPost(_, let model):
      return .body(model)
    case .editMeetingQuestion(_, let model):
      return .body(model)
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireDetailRecruitment, .inquireRecruitmentQuestion, .searchRecruitment, .requestBookmark, .editMeetingPost, .editMeetingQuestion:
      return .withAccessToken
    }
  }
}


