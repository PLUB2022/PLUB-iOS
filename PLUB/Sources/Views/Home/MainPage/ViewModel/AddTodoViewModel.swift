//
//  AddTodoViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/10.
//

import RxSwift

protocol AddTodoListViewModelType {
  var whichCreateTodoRequest: AnyObserver<CreateTodoRequest> { get }
}

final class AddTodoListViewModel: AddTodoListViewModelType {
  
  private let disposeBag = DisposeBag()
  
  private(set) var plubbingID: Int = 0
  private let createTodoRequst = PublishSubject<CreateTodoRequest>()
  
  init(plubbingID: Int) {
    self.plubbingID = plubbingID
    tryCreateTodo()
  }
  
  private func tryCreateTodo() {
    let requestCreateTodo = createTodoRequst
      .withUnretained(self)
      .flatMapLatest { owner, request in
        TodolistService.shared.createTodo(plubbingID: owner.plubbingID, request: request)
      }
    
    requestCreateTodo.subscribe(onNext: { response in
      Log.debug("투두생성응답값 \(response)")
    })
      .disposed(by: disposeBag)
  }
}

extension AddTodoListViewModel {
  var whichCreateTodoRequest: AnyObserver<CreateTodoRequest> {
    createTodoRequst.asObserver()
  }
}
