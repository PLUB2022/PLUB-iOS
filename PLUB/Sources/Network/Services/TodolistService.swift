//
//  TodolistService.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/28.
//

import RxSwift

final class TodolistService: BaseService {
  static let shared = TodolistService()
  
  private override init() { }
}

extension TodolistService {
  func inquireAllTodoTimeline(plubbingID: Int, cursorID: Int = 0) -> PLUBResult<PaginatedDataResponse<InquireAllTodoTimelineResponse>> {
    sendRequest(
      TodolistRouter.inquireAllTodoTimeline(plubbingID, cursorID),
      type: PaginatedDataResponse<InquireAllTodoTimelineResponse>.self
    )
  }
  
  func inquireTodolist(plubbingID: Int, timelineID: Int) -> Observable<InquireTodolistResponse> {
    sendObservableRequest(TodolistRouter.inquireTodolist(plubbingID, timelineID))
  }
}
