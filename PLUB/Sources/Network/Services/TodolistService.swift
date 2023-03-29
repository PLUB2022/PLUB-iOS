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
  func inquireAllTodolist(plubbingID: Int, cursorID: Int = 0) -> PLUBResult<FeedsPaginatedDataResponse<InquireAllTodolistResponse>> {
    sendRequest(
      TodolistRouter.inquireAllTodolist(plubbingID, cursorID),
      type: FeedsPaginatedDataResponse<InquireAllTodolistResponse>.self
    )
  }
}
