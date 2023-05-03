//
//  InquireMyTodoUseCase.swift
//  PLUB
//
//  Created by 김수빈 on 2023/05/04.
//

import UIKit

import RxSwift

protocol InquireMyTodoUseCase {
  func execute(plubbingID: Int, cursorID: Int) -> Observable<MyTodoResponse>
}

final class DefaultInquireMyTodoUseCase: InquireMyTodoUseCase {
  
  func execute(plubbingID: Int, cursorID: Int) -> Observable<MyTodoResponse> {
    MyPageService.shared
      .inquireMyTodo(plubbingID: plubbingID, cursorID: cursorID)
  }
}
