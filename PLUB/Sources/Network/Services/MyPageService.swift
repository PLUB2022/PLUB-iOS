//
//  MyPageService.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/13.
//

import RxSwift

class MyPageService: BaseService {
  static let shared = MyPageService()
  
  private override init() { }
}

extension MyPageService {
  func inquireMyMeeting(
    status: PlubbingStatusType,
    cursorID: Int
  ) -> PLUBResult<MyPlubbingResponse> {
    return sendRequest(
      MyPageRouter.inquireMyMeeting(
        .init(
          status:status.rawValue,
          cursorId: cursorID
        )
      ), type: MyPlubbingResponse.self)
  }
}
