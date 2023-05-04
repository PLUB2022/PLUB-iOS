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

final class TodolistViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let selectingPlubbingID = PublishSubject<Int>()
  private let allTodoTimeline = BehaviorSubject<[InquireAllTodoTimelineResponse]>(value: [])
  
  init() {
    inquireAllTodoTimeline()
  }
  
  private func inquireAllTodoTimeline() {
    let inquireAllTodoTimeline = selectingPlubbingID.flatMapLatest {
      return TodolistService.shared.inquireAllTodoTimeline(plubbingID: $0, cursorID: 0)
    }
      .share()
    
    let successInquireAllTodoTimeline = inquireAllTodoTimeline.compactMap { result -> [InquireAllTodoTimelineResponse]? in
      guard case .success(let response) = result else { return nil }
      return response.data?.content
    }
    
    successInquireAllTodoTimeline
      .bind(to: allTodoTimeline)
      .disposed(by: disposeBag)
  }
}

extension TodolistViewModel: TodolistViewModelType {
  var selectPlubbingID: AnyObserver<Int> { // 선택한 plubbingID가 무엇인지
    selectingPlubbingID.asObserver()
  }
  
  var todoTimelineModel: Driver<[TodolistModel]> { // 조회한 투두타임라인에 대한 데이터를 TodolistModel로 파싱한 값
    allTodoTimeline.map { result in
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
      return todolistModel
    }
    .asDriver(onErrorDriveWith: .empty())
  }
}
