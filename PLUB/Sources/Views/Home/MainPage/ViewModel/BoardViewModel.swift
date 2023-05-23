//
//  BoardViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/02.
//

import RxSwift
import RxCocoa
import Foundation

protocol BoardViewModelType {
  // Intput
  var selectPlubbingID: AnyObserver<Int> { get }
  var selectFeedID: AnyObserver<Int> { get }
  var selectFix: AnyObserver<Void> { get }
  //  var selectModify: AnyObserver<Void> { get }
  //  var selectReport: AnyObserver<Void> { get }
  var selectDelete: AnyObserver<Void> { get }
  var fetchMoreDatas: AnyObserver<Void> { get }
  
  // Output
  var fetchedMainpageClipboardViewModel: Driver<[MainPageClipboardViewModel]> { get }
  var fetchedBoardModel: Driver<[BoardModel]> { get }
  var clipboardListIsEmpty: Driver<Bool> { get }
  var isPinnedFeed: Driver<Int> { get }
  var successDeleteFeed: Driver<Void> { get }
  
  func clearStatus()
  
}

final class BoardViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let selectingPlubbingID = PublishSubject<Int>()
  private let selectingFeedID = PublishSubject<Int>()
  private let selectingFix = PublishSubject<Void>()
  private let selectingDelete = PublishSubject<Void>()
  private let fetchingMainpageClipboardViewModel = BehaviorRelay<[MainPageClipboardViewModel]>(value: [])
  private let fetchingBoardModel = BehaviorRelay<[BoardModel]>(value: [])
  private let fetchingMoreDatas = PublishSubject<Void>()
  private let currentCursorID = BehaviorRelay<Int>(value: 0)
  private let isLastPage = BehaviorSubject<Bool>(value: false)
  private let isLoading = BehaviorSubject<Bool>(value: false)
  
  
  init() {
    tryFetchingBoards()
    tryFetchingClipboards()
    tryFetchingMoreDatas()
  }
  
  func clearStatus() {
    isLastPage.onNext(false)
    isLoading.onNext(false)
    currentCursorID.accept(0)
  }
  
  private func tryFetchingBoards() {
    let fetchingBoards =
    Observable.combineLatest(
      selectingPlubbingID,
      currentCursorID
    ) { ($0, $1) }
      .withUnretained(self)
      .filter { owner, _ in try !owner.isLastPage.value() && !owner.isLoading.value() }
      .flatMapLatest { owner, result in
        let (plubbingID, cursorID) = result
        owner.isLoading.onNext(true)
        return FeedsService.shared.fetchBoards(
          plubbingID: plubbingID,
          nextCursorID: cursorID
        )
      }
    
    fetchingBoards.subscribe(with: self) { owner, boards in
      let boardModels = boards.content.map { $0.toBoardModel }
      owner.fetchingBoardModel.accept(boardModels)
      owner.isLoading.onNext(false)
      owner.isLastPage.onNext(boards.isLast)
    }
    .disposed(by: disposeBag)
  }
  
  private func tryFetchingClipboards() {
    let fetchingClipboards = selectingPlubbingID
      .flatMapLatest { plubbingID in
        return FeedsService.shared.fetchClipboards(plubbingID: plubbingID)
      }
    
    fetchingClipboards.subscribe(with: self) { owner, contents in
      let mainPageClipboardViewModel = contents.pinnedFeedList.map {
        return MainPageClipboardViewModel(
          type: $0.type,
          contentImageString: $0.feedImageURL,
          contentText: $0.content
        )
      }
      owner.fetchingMainpageClipboardViewModel.accept(mainPageClipboardViewModel)
    }
    .disposed(by: disposeBag)
  }
  
  private func tryFetchingMoreDatas() {
    fetchingMoreDatas.withLatestFrom(currentCursorID)
      .withUnretained(self)
      .filter({ owner, _ in
        try owner.isLastPage.value() || owner.isLoading.value() ? false : true
      })
      .map { $1 + 1 }
      .bind(to: currentCursorID)
      .disposed(by: disposeBag)
  }
}

extension BoardViewModel: BoardViewModelType {
  
  // Input
  var selectPlubbingID: AnyObserver<Int> {
    selectingPlubbingID.asObserver()
  }
  
  var selectFeedID: AnyObserver<Int> {
    selectingFeedID.asObserver()
  }
  
  var selectFix: AnyObserver<Void> {
    selectingFix.asObserver()
  }
  
  //  let selectModify: AnyObserver<Void>
  //  let selectReport: AnyObserver<Void>
  var selectDelete: AnyObserver<Void> {
    selectingDelete.asObserver()
  }
  
  var fetchMoreDatas: AnyObserver<Void> {
    fetchingMoreDatas.asObserver()
  }
  
  // Output
  var fetchedMainpageClipboardViewModel: Driver<[MainPageClipboardViewModel]> {
    fetchingMainpageClipboardViewModel.asDriver(onErrorDriveWith: .empty())
  }
  
  var fetchedBoardModel: Driver<[BoardModel]> {
    fetchingBoardModel
      .asDriver(onErrorDriveWith: .empty())
  }
  
  var clipboardListIsEmpty: Driver<Bool> {
    fetchingMainpageClipboardViewModel
      .map { $0.isEmpty }
      .asDriver(onErrorDriveWith: .empty())
  }
  
  var isPinnedFeed: Driver<Int> {
    selectingFix.withLatestFrom(
      Observable.zip(
        selectingPlubbingID,
        selectingFeedID
      )
    )
    .flatMapLatest(FeedsService.shared.pinFeed)
    .map { $0.feedID }
    .asDriver(onErrorDriveWith: .empty())
  }
  
  var successDeleteFeed: Driver<Void> {
    selectingDelete.withLatestFrom(
      Observable.zip(
        selectingPlubbingID,
        selectingFeedID
      )
    )
    .flatMapLatest(FeedsService.shared.deleteFeed)
    .map { _ in Void() }
    .asDriver(onErrorDriveWith: .empty())
  }
}
