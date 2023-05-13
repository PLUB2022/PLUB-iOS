//
//  TodolistViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/02.
//

import UIKit

import RxSwift
import RxCocoa

protocol TodolistViewModelType {
  // Input
  var selectComplete: AnyObserver<Bool> { get }
  var selectPlubbingID: AnyObserver<Int> { get }
  var selectTodolistID: AnyObserver<Int> { get }
  var whichProofImage: AnyObserver<UIImage?> { get }
  var selectLikeButton: AnyObserver<Int> { get }
  
  // Output
  var todoTimelineModel: Driver<[TodolistModel]> { get }
  var successCompleteTodolist: Signal<Bool> { get }
  var successProofTodolist: Signal<CompleteProofTodolistResponse> { get }
}

final class TodolistViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let selectingComplete = PublishSubject<Bool>()
  private let selectingPlubbingID = PublishSubject<Int>()
  private let selectingTodolistID = PublishSubject<Int>()
  private let allTodoTimeline = BehaviorSubject<[InquireAllTodoTimelineResponse]>(value: [])
  private let completeTodolist = PublishSubject<CompleteProofTodolistResponse>()
  private let proofTodolist = PublishSubject<CompleteProofTodolistResponse>()
  private let whichUploadingImage = PublishSubject<UIImage?>()
  private let selectingLikeButton = PublishSubject<Int>()
  
  init() {
    inquireAllTodoTimeline()
    tryCompleteTodolist()
    tryCancelCompleteTodolist()
    tryProofTodolist()
    tryLikeTodolist()
  }
  
  private func inquireAllTodoTimeline() {
    let inquireAllTodoTimeline = selectingPlubbingID.flatMapLatest {
      return TodolistService.shared.inquireAllTodoTimeline(
        plubbingID: $0,
        cursorID: 0
      )
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
  
  private func tryCompleteTodolist() {
    let completeTodolist = selectingComplete
      .filter { $0 }
      .withLatestFrom(
        Observable.combineLatest(
          selectingPlubbingID,
          selectingTodolistID
        )
      )
      .flatMapLatest(TodolistService.shared.completeTodolist)
      
    completeTodolist.subscribe(onNext: { response in
      Log.debug("완료 \(response) ")
    })
    .disposed(by: disposeBag)
  }
  
  private func tryCancelCompleteTodolist() {
    let cancelCompleteTodolist = selectingComplete
      .filter { !$0 }
      .withLatestFrom(
        Observable.combineLatest(
          selectingPlubbingID,
          selectingTodolistID
        )
      )
      .flatMapLatest(TodolistService.shared.cancelCompleteTodolist)
    
    cancelCompleteTodolist.subscribe(onNext: { response in
      Log.debug("취소완료 \(response) ")
    })
    .disposed(by: disposeBag)
  }
  
  private func getProofImage() -> Observable<String> { // 투두리스트 인증을 위한 이미지를 받아오는 함수
    let uploadImage = whichUploadingImage
      .compactMap { $0 }
      .flatMapLatest { image in
        ImageService.shared.uploadImage(
          images: [image],
          params: .init(type: .feed)
        )
      }
    
    let tryImageToString = uploadImage
      .flatMap { response -> Observable<String?> in
        switch response {
        case let .success(imageModel):
          return .just(imageModel.data?.files.first?.fileURL)
        default:
          // 이미지 등록이 되지 못함 (오류 발생)
          return .empty()
        }
      }
    
    return tryImageToString.compactMap { $0 }
  }
  
  private func tryProofTodolist() { // 투두리스트 인증에 대한 API를 호출하는 함수
    let proofTodolist = Observable.combineLatest(
      selectingPlubbingID,
      selectingTodolistID,
      getProofImage().map { ProofTodolistRequest(proofImage: $0) }
    )
      .flatMapLatest(TodolistService.shared.proofTodolist)
    
    proofTodolist.subscribe(with: self) { owner, response in
      owner.proofTodolist.onNext(response)
    }
    .disposed(by: disposeBag)
  }
  
  private func tryLikeTodolist() {
    let likeTodolist = selectingLikeButton
      .withLatestFrom(selectingPlubbingID) { ($0, $1) }
      .flatMapLatest { TodolistService.shared.likeTodolist(plubbingID: $1, timelineID: $0) }
    
    likeTodolist.subscribe(onNext: { response in
      Log.debug("좋아요 응답값 \(response)")
    })
    .disposed(by: disposeBag)
  }
  
  private func parseFromResponseToModel(response: [InquireAllTodoTimelineResponse]) -> [TodolistModel] {
    let todolistModel = response.compactMap { response -> TodolistModel? in
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
  
  private func sortedModelByDate(model: [TodolistModel]) -> [TodolistModel] {
    return model.sorted { first, second in
      
      guard let firstDate = DateFormatterFactory.todolistDate.date(from: first.headerModel.date),
            let secondDate = DateFormatterFactory.todolistDate.date(from: second.headerModel.date) else { return false }
      
      if first.headerModel.isToday != second.headerModel.isToday {
          return first.headerModel.isToday
      }
      return firstDate > secondDate
    }
  }
}

extension TodolistViewModel: TodolistViewModelType {
 
  var selectPlubbingID: AnyObserver<Int> { // 선택한 plubbingID가 무엇인지
    selectingPlubbingID.asObserver()
  }
  
  var selectTodolistID: AnyObserver<Int> {
    selectingTodolistID.asObserver()
  }
  
  var selectComplete: AnyObserver<Bool> {
    selectingComplete.asObserver()
  }
  
  var whichProofImage: AnyObserver<UIImage?> {
    whichUploadingImage.asObserver()
  }
  
  var selectLikeButton: AnyObserver<Int> {
    selectingLikeButton.asObserver()
  }
  
  var todoTimelineModel: Driver<[TodolistModel]> { // 조회한 투두타임라인에 대한 데이터를 TodolistModel로 파싱한 값
    allTodoTimeline
      .withUnretained(self)
      .map { owner, response in
        let model = owner.parseFromResponseToModel(response: response)
        return owner.sortedModelByDate(model: model)
      }
      .asDriver(onErrorDriveWith: .empty())
  }
  
  var successCompleteTodolist: Signal<Bool> {
    completeTodolist
      .map { $0.isChecked }
      .asSignal(onErrorSignalWith: .empty())
  }
  
  var successProofTodolist: Signal<CompleteProofTodolistResponse> {
    proofTodolist
      .asSignal(onErrorSignalWith: .empty())
  }
}
