//
//  AddTodoViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/10.
//

import Foundation

import RxSwift
import RxCocoa
import RxRelay

protocol AddTodoListViewModelType {
  var whichCreateTodoRequest: AnyObserver<CreateTodoRequest> { get }
  var whichInquireDate: AnyObserver<Date> { get }
  var selectPlubbingID: AnyObserver<Int> { get }
  
  var todolistModelByDate: Driver<AddTodoViewModel> { get }
}

final class AddTodoListViewModel: AddTodoListViewModelType {
  
  private let disposeBag = DisposeBag()
  
  private let whichPlubbingID = PublishSubject<Int>()
  private let createTodoRequst = PublishSubject<CreateTodoRequest>()
  private let inquireDate = PublishSubject<Date>()
  private let todolistModelByCurrentDate = PublishRelay<AddTodoViewModel>()
  
  init() {
    tryCreateTodo()
    tryInquireTodolistByDate()
  }
  
  private func tryCreateTodo() {
    let requestCreateTodo =
    Observable.combineLatest(
      whichPlubbingID,
      createTodoRequst
    )
      .flatMapLatest { plubbingID, request in
        TodolistService.shared.createTodo(plubbingID: plubbingID, request: request)
      }
    
    requestCreateTodo.subscribe(onNext: { response in
      Log.debug("투두생성응답값 \(response)")
    })
      .disposed(by: disposeBag)
  }
  
  private func tryInquireTodolistByDate() {
    let inquireTodolistByDate =
    Observable.combineLatest(
      whichPlubbingID,
      inquireDate.map { DateFormatterFactory.dateWithHypen.string(from: $0) }
    )
      .flatMapLatest { plubbingID, date in
        return TodolistService.shared.inquireTodolistByDate(
          plubbingID: plubbingID,
          todoDate: date
        )
      }
    
    inquireTodolistByDate
      .map { AddTodoViewModel(response: $0) }
      .bind(to: todolistModelByCurrentDate)
      .disposed(by: disposeBag)
  }
}

extension AddTodoListViewModel {
  
  var selectPlubbingID: AnyObserver<Int> {
    whichPlubbingID.asObserver()
  }
  
  var whichCreateTodoRequest: AnyObserver<CreateTodoRequest> {
    createTodoRequst.asObserver()
  }
  
  var whichInquireDate: AnyObserver<Date> {
    inquireDate.asObserver()
  }
  
  var todolistModelByDate: Driver<AddTodoViewModel> {
    todolistModelByCurrentDate
      .asDriver(onErrorDriveWith: .empty())
  }
}
