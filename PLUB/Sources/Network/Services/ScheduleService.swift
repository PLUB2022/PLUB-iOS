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
  func createSchedule(plubbingID: String, request: CreateScheduleRequest) -> PLUBResult<CreateScheduleResponse> {
    return sendRequest(
      ScheduleRouter.createSchedule(plubbingID, request),
      type: CreateScheduleResponse.self
    )
  }
}
