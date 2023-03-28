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
  func inquireAllTodolist(plubbingID: Int) -> PLUBResult<FeedsPaginatedDataResponse<FeedsContent>> {
    sendRequest(
      TodolistRouter.inquireAllTodolist(plubbingID),
      type: FeedsPaginatedDataResponse<FeedsContent>.self
    )
  }
}
