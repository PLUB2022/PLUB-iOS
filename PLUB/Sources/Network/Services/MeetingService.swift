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
  
  func editMeetingInfo(plubbingID: String, request: EditMeetingInfoRequest) -> Observable<NetworkResult<GeneralResponse<CreateMeetingResponse>>> {
    return sendRequest(
      MeetingRouter.editMeetingInfo(plubbingID, request),
      type: CreateMeetingResponse.self
    )
  }
  
  func inquireCategoryMeeting(categoryId: String, page: Int, sort: String) -> Observable<NetworkResult<GeneralResponse<CategoryMeetingResponse>>>  {
    return sendRequest(MeetingRouter.inquireCategoryMeeting(categoryId, page, sort), type: CategoryMeetingResponse.self)
  }
  
  func inquireRecommendationMeeting(page: Int) -> Observable<NetworkResult<GeneralResponse<CategoryMeetingResponse>>> {
    return sendRequest(MeetingRouter.inquireRecommendationMeeting(page), type: CategoryMeetingResponse.self)
  }
}
