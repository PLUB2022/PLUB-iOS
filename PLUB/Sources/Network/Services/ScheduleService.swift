//
//  ScheduleService.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/19.
//

import RxSwift

class ScheduleService: BaseService {
  static let shared = ScheduleService()
  
  private override init() { }
}

extension ScheduleService {
  func createSchedule(plubbingID: Int, request: CreateScheduleRequest) -> PLUBResult<CreateScheduleResponse> {
    return sendRequest(
      ScheduleRouter.createSchedule(plubbingID, request),
      type: CreateScheduleResponse.self
    )
  }
  
  func inquireScheduleList(plubbingID: Int, cursorID: Int?) -> Observable<ScheduleListResponse>  {
    sendObservableRequest(ScheduleRouter.inquireScheduleList(plubbingID, cursorID))
  }
  
  func attendSchedule(
    plubbingID: Int,
    calendarID: Int,
    request: AttendScheduleRequest
  ) -> PLUBResult<AttendScheduleResponse> {
    return sendRequest(
      ScheduleRouter.attendSchedule(plubbingID, calendarID, request),
      type: AttendScheduleResponse.self
    )
  }
  
  func inquireScheduleDetail(
    plubbingID: Int,
    calendarID: Int
  ) -> Observable<Schedule>  {
    sendObservableRequest(ScheduleRouter.inquireScheduleDetail(plubbingID, calendarID))
  }
  
  func editSchedule(
    plubbingID: Int,
    calendarID: Int,
    request: CreateScheduleRequest
  ) -> Observable<CreateScheduleResponse>  {
    sendObservableRequest(ScheduleRouter.editSchedule(plubbingID, calendarID, request))
  }
  
  func deleteSchedule(
    plubbingID: Int,
    calendarID: Int
  ) -> Observable<EmptyModel>  {
    sendObservableRequest(ScheduleRouter.deleteSchedule(plubbingID, calendarID))
  }
}
