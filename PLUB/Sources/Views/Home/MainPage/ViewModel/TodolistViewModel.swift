//
//  TodolistViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/02.
//

import Foundation

import RxSwift
import RxCocoa

protocol TodolistViewModelType {
  // Input
  var selectPlubbingID: AnyObserver<Int> { get }
  
  // Output
  var todolistDateModel: Driver<[TodoCollectionHeaderViewModel]> { get }
}

final class TodolistViewModel: TodolistViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let selectPlubbingID: AnyObserver<Int>
  
  let todolistDateModel: Driver<[TodoCollectionHeaderViewModel]>
  
  init() {
    let selectingPlubbingID = PublishSubject<Int>()
    let allTodolist = BehaviorSubject<[InquireAllTodolistResponse]>(value: [])
    self.selectPlubbingID = selectingPlubbingID.asObserver()
    
    let inquireAllTodolist = selectingPlubbingID.flatMapLatest {
      return TodolistService.shared.inquireAllTodolist(plubbingID: $0, cursorID: 0)
    }
      .share()
    
    let successInquireAllTodolist = inquireAllTodolist.compactMap { result -> [InquireAllTodolistResponse]? in
      guard case .success(let response) = result else { return nil }
      return response.data?.content
    }
    
    successInquireAllTodolist
      .subscribe(onNext: { response in
        allTodolist.onNext(response)
      })
      .disposed(by: disposeBag)
    
    todolistDateModel = allTodolist.map { result in
      return result.compactMap { response -> TodoCollectionHeaderViewModel? in
        guard let date = DateFormatterFactory.dateWithHypen.date(from: response.date) else {
          return nil
        }
        return TodoCollectionHeaderViewModel(
          isToday: Calendar.current.isDateInToday(date),
          date: DateFormatterFactory.todolistDate.string(from: date)
        )
      }
    }
    .asDriver(onErrorDriveWith: .empty())
  }
}
