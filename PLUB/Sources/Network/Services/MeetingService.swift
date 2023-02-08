//
//  CategoryService.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import RxSwift

// TODO: -이건준 추천모임조회 응답모델 코드 수정
class MeetingService: BaseService {
  static let shared = MeetingService()
  
  private override init() { }
}

extension MeetingService {
  func createMeeting(request: CreateMeetingRequest) -> Observable<NetworkResult<GeneralResponse<CreateMeetingResponse>>> {
    return sendRequest(
      MeetingRouter.createMeeting(request),
      type: CreateMeetingResponse.self
    )
  }
  
  func editMeeting(plubbingId: Int, request: EditMeetingRequest) -> Observable<NetworkResult<GeneralResponse<CreateMeetingResponse>>> {
    return sendRequest(
      MeetingRouter.editMeeting(plubbingId, request),
      type: CreateMeetingResponse.self
    )
  }
  
  func inquireCategoryMeeting(categoryId: String, page: Int = 1, sort: String) -> Observable<NetworkResult<GeneralResponse<CategoryMeetingResponse>>>  {
    return sendRequest(MeetingRouter.inquireCategoryMeeting(categoryId, page, sort), type: CategoryMeetingResponse.self)
  }
  
  func inquireRecommendationMeeting() -> Observable<NetworkResult<GeneralResponse<CategoryMeetingResponse>>> {
    return sendRequest(MeetingRouter.inquireRecommendationMeeting, type: CategoryMeetingResponse.self)
  }
}
