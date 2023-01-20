//
//  CategoryService.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import RxSwift

class MeetingService: BaseService {
  static let shared = MeetingService()
  
  private override init() { }
}

extension MeetingService {
  func inquireCategoryMeeting(categoryId: Int, query: MeetingQuery) -> Observable<NetworkResult<GeneralResponse<CategoryMeetingResponse>>>  {
    return sendRequest(MeetingRouter.inquireCategoryMeeting(categoryId, query), type: CategoryMeetingResponse.self)
  }
}
