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
  var todoTimelineModel: Driver<[TodolistModel]> { get }
}

final class TodolistViewModel: TodolistViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let selectPlubbingID: AnyObserver<Int>
  
  let todoTimelineModel: Driver<[TodolistModel]>
  
  init() {
    let selectingPlubbingID = PublishSubject<Int>()
    let allTodoTimeline = BehaviorSubject<[InquireAllTodoTimelineResponse]>(value: [])
    self.selectPlubbingID = selectingPlubbingID.asObserver()
    
    let inquireAllTodoTimeline = selectingPlubbingID.flatMapLatest {
      return TodolistService.shared.inquireAllTodoTimeline(plubbingID: $0, cursorID: 0)
    }
      .share()
    
    let successInquireAllTodoTimeline = inquireAllTodoTimeline.compactMap { result -> [InquireAllTodoTimelineResponse]? in
      guard case .success(let response) = result else { return nil }
      return response.data?.content
    }
    
    successInquireAllTodoTimeline
      .subscribe(onNext: { response in
        allTodoTimeline.onNext(response)
      })
      .disposed(by: disposeBag)
    
    todoTimelineModel = allTodoTimeline.map { result in
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
