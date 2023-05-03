//
//  MyPageService.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/13.
//

import RxSwift

final class MyPageService: BaseService {
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
          status:status,
          cursorID: cursorID
        )
      ), type: MyPlubbingResponse.self)
  }
  
  func inquireMyTodo(
    plubbingID: Int,
    cursorID: Int
  ) -> Observable<MyTodoResponse>  {
    sendObservableRequest(MyPageRouter.inquireMyTodo(plubbingID, cursorID))
  }
}
