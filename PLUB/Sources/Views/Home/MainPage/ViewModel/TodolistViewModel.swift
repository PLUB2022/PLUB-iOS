//
//  TodolistViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/02.
//

import RxSwift

protocol TodolistViewModelType {
  var selectPlubbingID: AnyObserver<Int> { get }
}

final class TodolistViewModel: TodolistViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let selectPlubbingID: AnyObserver<Int>
  
  init() {
    let selectingPlubbingID = PublishSubject<Int>()
    self.selectPlubbingID = selectingPlubbingID.asObserver()
    
    let inquireAllTodolist = selectingPlubbingID.flatMap {
      return TodolistService.shared.inquireAllTodolist(plubbingID: $0, cursorID: 0)
    }
    
    let successInquireAllTodolist = inquireAllTodolist.compactMap { result -> [InquireAllTodolistResponse]? in
      guard case .success(let response) = result else { return nil }
      return response.data?.content
    }
    
    successInquireAllTodolist
      .subscribe(onNext: { model in
        print("콘텐츠 \(model)")
      })
      .disposed(by: disposeBag)
  }
}
