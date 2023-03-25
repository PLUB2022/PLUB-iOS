//
//  CategoryRouter.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import Alamofire

enum RecruitmentRouter {
  case inquireAllBookmark
  case inquireDetailRecruitment(Int)
  case inquireRecruitmentQuestion(Int)
  case searchRecruitment(SearchParameter)
  case requestBookmark(Int)
  case editMeetingPost(Int, EditMeetingPostRequest)
  case editMeetingQuestion(Int, EditMeetingQuestionRequest)
  case applyForRecruitment(Int, ApplyForRecruitmentRequest)
  case inquireApplicant(Int)
  case approvalApplicant(Int, Int)
  case refuseApplicant(Int, Int)
}

extension RecruitmentRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .inquireDetailRecruitment, .inquireRecruitmentQuestion, .inquireAllBookmark, .searchRecruitment, .inquireApplicant:
      return .get
    case .requestBookmark, .applyForRecruitment, .approvalApplicant, .refuseApplicant:
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
    case .inquireAllBookmark:
      return "/plubbings/recruit/bookmarks/me"
    case .applyForRecruitment(let plubbingID, _):
      return "/plubbings/\(plubbingID)/recruit/applicants"
    case .inquireApplicant(let plubbingID):
      return "/plubbings/\(plubbingID)/recruit/applicants"
    case .approvalApplicant(let plubbingID, let accountID):
      return "/plubbings/\(plubbingID)/recruit/applicants/\(accountID)/approval"
    case .refuseApplicant(let plubbingID, let accountID):
      return "/plubbings/\(plubbingID)/recruit/applicants/\(accountID)/refuse"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireDetailRecruitment, .inquireRecruitmentQuestion, .inquireAllBookmark, .requestBookmark, .inquireApplicant, .approvalApplicant, .refuseApplicant:
      return .plain
    case .searchRecruitment(let parameter):
      return .query(parameter)
    case .editMeetingPost(_, let model):
      return .body(model)
    case .editMeetingQuestion(_, let model):
      return .body(model)
    case .applyForRecruitment(_, let model):
      return .body(model)
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireDetailRecruitment, .inquireRecruitmentQuestion, .inquireAllBookmark, .searchRecruitment, .requestBookmark, .editMeetingPost, .editMeetingQuestion, .applyForRecruitment, .inquireApplicant, .approvalApplicant, .refuseApplicant:
      return .withAccessToken
    }
  }
}


