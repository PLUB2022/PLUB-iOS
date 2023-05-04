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
  var todolistModel: Driver<[TodolistModel]> { get }
}

final class TodolistViewModel: TodolistViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let selectPlubbingID: AnyObserver<Int>
  
  let todolistModel: Driver<[TodolistModel]>
  
  init() {
    let selectingPlubbingID = PublishSubject<Int>()
    let allTodolist = BehaviorSubject<[InquireAllTodolistResponse]>(value: [])
    self.selectPlubbingID = selectingPlubbingID.asObserver()
    
    let inquireAllTodolist = selectingPlubbingID.flatMapLatest {
      return TodolistService.shared.inquireAllTodoTimeline(plubbingID: $0, cursorID: 0)
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
    
    todolistModel = allTodolist.map { result in
      let todolistModel = result.compactMap { response -> TodolistModel? in
        guard let date = DateFormatterFactory.dateWithHypen.date(from: response.date) else {
          return nil
        }
        let headerModel = TodoCollectionHeaderViewModel(
          isToday: Calendar.current.isDateInToday(date),
          date: DateFormatterFactory.todolistDate.string(from: date)
        )
        
        let cellModel = TodoCollectionViewCellModel(response: response)
        return TodolistModel(headerModel: headerModel, cellModel: cellModel)
      }
      return todolistModel.sorted(by: { $0.cellModel.isAuthor && !$1.cellModel.isAuthor})
    }
    .asDriver(onErrorDriveWith: .empty())
  }
}
