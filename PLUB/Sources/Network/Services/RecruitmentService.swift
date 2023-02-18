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
  func inquireDetailRecruitment(plubbingID: String) -> Observable<NetworkResult<GeneralResponse<DetailRecruitmentResponse>>> {
    return sendRequest(RecruitmentRouter.inquireDetailRecruitment(plubbingID), type: DetailRecruitmentResponse.self)
  }
  
  func inquireRecruitmentQuestion(plubbingID: String) -> Observable<NetworkResult<GeneralResponse<RecruitmentQuestionResponse>>> {
    return sendRequest(RecruitmentRouter.inquireRecruitmentQuestion(plubbingID), type: RecruitmentQuestionResponse.self)
  }
  
  func inquireBookmarkAll() -> Observable<NetworkResult<GeneralResponse<BookmarkAllResponse>>> {
    return sendRequest(RecruitmentRouter.inquireAllBookmark, type: BookmarkAllResponse.self)
  }
  
  func searchRecruitment(searchParameter: SearchParameter) -> Observable<NetworkResult<GeneralResponse<SearchRecruitmentResponse>>> {
    return sendRequest(RecruitmentRouter.searchRecruitment(searchParameter), type: SearchRecruitmentResponse.self)
  }
  
  func requestBookmark(plubbingID: String) -> Observable<NetworkResult<GeneralResponse<RequestBookmarkResponse>>> {
    return sendRequest(RecruitmentRouter.requestBookmark(plubbingID), type: RequestBookmarkResponse.self)
  }
  
  func editMeetingPost(plubbingID: String, request: EditMeetingPostRequest) -> Observable<NetworkResult<GeneralResponse<EmptyModel>>> {
    return sendRequest(RecruitmentRouter.editMeetingPost(plubbingID, request))
  }
  
  func editMeetingQuestion(plubbingID: String, request: EditMeetingQuestionRequest) -> Observable<NetworkResult<GeneralResponse<EmptyModel>>> {
    return sendRequest(RecruitmentRouter.editMeetingQuestion(plubbingID, request))
  }
}
