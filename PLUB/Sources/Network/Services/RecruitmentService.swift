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
  func inquireDetailRecruitment(plubbingID: String) -> PLUBResult<DetailRecruitmentResponse> {
    return sendRequest(RecruitmentRouter.inquireDetailRecruitment(plubbingID), type: DetailRecruitmentResponse.self)
  }
  
  func inquireRecruitmentQuestion(plubbingID: String) -> PLUBResult<RecruitmentQuestionResponse> {
    return sendRequest(RecruitmentRouter.inquireRecruitmentQuestion(plubbingID), type: RecruitmentQuestionResponse.self)
  }
  
  func inquireBookmarkAll() -> PLUBResult<BookmarkAllResponse> {
    return sendRequest(RecruitmentRouter.inquireAllBookmark, type: BookmarkAllResponse.self)
  }
  
  func searchRecruitment(searchParameter: SearchParameter) -> PLUBResult<SearchRecruitmentResponse> {
    return sendRequest(RecruitmentRouter.searchRecruitment(searchParameter), type: SearchRecruitmentResponse.self)
  }
  
  func requestBookmark(plubbingID: String) -> PLUBResult<RequestBookmarkResponse> {
    return sendRequest(RecruitmentRouter.requestBookmark(plubbingID), type: RequestBookmarkResponse.self)
  }
  
  func editMeetingPost(plubbingID: String, request: EditMeetingPostRequest) -> PLUBResult<EmptyModel> {
    return sendRequest(RecruitmentRouter.editMeetingPost(plubbingID, request))
  }
  
  func editMeetingQuestion(plubbingID: String, request: EditMeetingQuestionRequest) -> PLUBResult<EmptyModel> {
    return sendRequest(RecruitmentRouter.editMeetingQuestion(plubbingID, request))
  }
  
  func inquireApplicant(plubbingID: String) -> PLUBResult<InquireApplicantResponse> {
    return sendRequest(RecruitmentRouter.inquireApplicant(plubbingID), type: InquireApplicantResponse.self)
  }
}
