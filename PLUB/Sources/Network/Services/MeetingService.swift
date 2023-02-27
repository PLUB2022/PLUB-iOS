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
  func createMeeting(request: CreateMeetingRequest) -> PLUBResult<CreateMeetingResponse> {
    return sendRequest(
      MeetingRouter.createMeeting(request),
      type: CreateMeetingResponse.self
    )
  }
  
  func editMeetingInfo(plubbingID: String, request: EditMeetingInfoRequest) -> PLUBResult<CreateMeetingResponse> {
    return sendRequest(
      MeetingRouter.editMeetingInfo(plubbingID, request),
      type: CreateMeetingResponse.self
    )
  }
  
  func inquireCategoryMeeting(categoryID: String, page: Int, sort: String, request: CategoryMeetingRequest?) -> PLUBResult<CategoryMeetingResponse>  {
    return sendRequest(MeetingRouter.inquireCategoryMeeting(categoryID, page, sort, request), type: CategoryMeetingResponse.self)
  }
  
  func inquireRecommendationMeeting(page: Int) -> PLUBResult<CategoryMeetingResponse> {
    return sendRequest(MeetingRouter.inquireRecommendationMeeting(page), type: CategoryMeetingResponse.self)
  }
}
