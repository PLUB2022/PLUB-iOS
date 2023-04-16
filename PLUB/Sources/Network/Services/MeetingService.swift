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
  
  func editMeetingInfo(plubbingID: Int, request: EditMeetingInfoRequest) -> PLUBResult<CreateMeetingResponse> {
    return sendRequest(
      MeetingRouter.editMeetingInfo(plubbingID, request),
      type: CreateMeetingResponse.self
    )
  }
  
  func inquireCategoryMeeting(categoryID: String, cursorID: Int, sort: String, request: CategoryMeetingRequest?) -> PLUBResult<CategoryMeetingResponse>  {
    return sendRequest(MeetingRouter.inquireCategoryMeeting(categoryID, cursorID, sort, request), type: CategoryMeetingResponse.self)
  }
  
  func inquireRecommendationMeeting(cursorID: Int = 0) -> PLUBResult<CategoryMeetingResponse> {
    return sendRequest(MeetingRouter.inquireRecommendationMeeting(cursorID), type: CategoryMeetingResponse.self)
  }
  
  func inquireMyMeeting(isHost: Bool) -> PLUBResult<MyMeetingResponse> {
    return sendRequest(MeetingRouter.inquireMyMeeting(isHost), type: MyMeetingResponse.self)
  }
  
  func deleteMeeting(plubbingID: Int) -> Observable<EmptyModel>  {
    sendObservableRequest(MeetingRouter.deleteMeeting(plubbingID))
  }
  
  func exitMeeting(plubbingID: Int) -> Observable<EmptyModel>  {
    sendObservableRequest(MeetingRouter.exitMeeting(plubbingID))
  }
  
  func exportMeetingMember(plubbingID: Int, accountID: Int) -> Observable<EmptyModel>  {
    sendObservableRequest(MeetingRouter.exportMeetingMember(plubbingID, accountID))
  }
  
  func inquireMeetingMember(plubbingID: Int) -> Observable<MeetingMemberResponse>  {
    sendObservableRequest(MeetingRouter.inquireMeetingMember(plubbingID))
  }
  
  func endMeeting(plubbingID: Int) -> Observable<EmptyModel>  {
    sendObservableRequest(MeetingRouter.endMeeting(plubbingID))
  }
}
