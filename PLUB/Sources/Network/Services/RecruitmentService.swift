//
//  CategoryService.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import RxSwift

class RecruitmentService: BaseService {
  static let shared = RecruitmentService()
  
  private override init() { }
}

extension RecruitmentService {
  func inquireDetailRecruitment(plubbingID: Int) -> PLUBResult<DetailRecruitmentResponse> {
    return sendRequest(RecruitmentRouter.inquireDetailRecruitment(plubbingID), type: DetailRecruitmentResponse.self)
  }
  
  func inquireRecruitmentQuestion(plubbingID: Int) -> PLUBResult<RecruitmentQuestionResponse> {
    return sendRequest(RecruitmentRouter.inquireRecruitmentQuestion(plubbingID), type: RecruitmentQuestionResponse.self)
  }
  
  func inquireBookmarkAll() -> PLUBResult<BookmarkAllResponse> {
    return sendRequest(RecruitmentRouter.inquireAllBookmark, type: BookmarkAllResponse.self)
  }
  
  func searchRecruitment(searchParameter: SearchParameter) -> PLUBResult<SearchRecruitmentResponse> {
    return sendRequest(RecruitmentRouter.searchRecruitment(searchParameter), type: SearchRecruitmentResponse.self)
  }
  
  func requestBookmark(plubbingID: Int) -> PLUBResult<RequestBookmarkResponse> {
    return sendRequest(RecruitmentRouter.requestBookmark(plubbingID), type: RequestBookmarkResponse.self)
  }
  
  func editMeetingPost(plubbingID: Int, request: EditMeetingPostRequest) -> PLUBResult<EmptyModel> {
    return sendRequest(RecruitmentRouter.editMeetingPost(plubbingID, request))
  }
  
  func editMeetingQuestion(plubbingID: Int, request: EditMeetingQuestionRequest) -> PLUBResult<EmptyModel> {
    return sendRequest(RecruitmentRouter.editMeetingQuestion(plubbingID, request))
  }
  
  func applyForRecruitment(plubbingID: Int, request: ApplyForRecruitmentRequest) -> PLUBResult<EmptyModel> {
    return sendRequest(RecruitmentRouter.applyForRecruitment(plubbingID, request))
  }
  
  func inquireApplicant(plubbingID: Int) -> PLUBResult<InquireApplicantResponse> {
    return sendRequest(RecruitmentRouter.inquireApplicant(plubbingID), type: InquireApplicantResponse.self)
  }
  
  func approvalApplicant(plubbingID: Int, accountID: Int) -> PLUBResult<EmptyModel> {
    return sendRequest(RecruitmentRouter.approvalApplicant(plubbingID, accountID))
  }
  
  func refuseApplicant(plubbingID: Int, accountID: Int) -> PLUBResult<EmptyModel> {
    return sendRequest(RecruitmentRouter.refuseApplicant(plubbingID, accountID))
  }
  
  func inquireMyApplication(plubbingID: Int) -> PLUBResult<MyApplicationResponse> {
    return sendRequest(RecruitmentRouter.inquireMyApplication(plubbingID), type: MyApplicationResponse.self)
  }
  
  func cancelApplication(plubbingID: Int) -> PLUBResult<EmptyModel> {
    return sendRequest(RecruitmentRouter.cancelApplication(plubbingID))
  }
  
  func endRecruitment(plubbingID: Int) -> Observable<EmptyModel> {
    return sendObservableRequest(RecruitmentRouter.endRecruitment(plubbingID))
  }
}
