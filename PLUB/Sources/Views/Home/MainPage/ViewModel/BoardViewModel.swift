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
  
}

final class BoardViewModel: BoardViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let selectPlubbingID: AnyObserver<Int>
  let selectFeedID: AnyObserver<Int>
  let selectFix: AnyObserver<Void>
  //  let selectModify: AnyObserver<Void>
  //  let selectReport: AnyObserver<Void>
  let selectDelete: AnyObserver<Void>
  let fetchMoreDatas: AnyObserver<Void>
  
  // Output
  let fetchedMainpageClipboardViewModel: Driver<[MainPageClipboardViewModel]>
  let fetchedBoardModel: Driver<[BoardModel]>
  let clipboardListIsEmpty: Driver<Bool>
  let isPinnedFeed: Driver<Int>
  let successDeleteFeed: Driver<Void>
  
  init() {
    let selectingPlubbingID = PublishSubject<Int>()
    let selectingFeedID = PublishSubject<Int>()
    let selectingFix = PublishSubject<Void>()
    let selectingDelete = PublishSubject<Void>()
    let fetchingMainpageClipboardViewModel = BehaviorRelay<[MainPageClipboardViewModel]>(value: [])
    let fetchingBoardModel = BehaviorRelay<[BoardModel]>(value: [])
    let fetchingMoreDatas = PublishSubject<Void>()
    let currentCursorID = BehaviorRelay<Int>(value: 0)
    let isLastPage = BehaviorSubject<Bool>(value: false)
    let isLoading = BehaviorSubject<Bool>(value: false)
    
    self.selectFeedID = selectingFeedID.asObserver()
    self.selectPlubbingID = selectingPlubbingID.asObserver()
    self.selectFix = selectingFix.asObserver()
    self.selectDelete = selectingDelete.asObserver()
    self.fetchMoreDatas = fetchingMoreDatas.asObserver()
    
    // Input
    let fetchingBoards =
    Observable.combineLatest(
      selectingPlubbingID,
      currentCursorID
    )
    .filter { _ in try !isLastPage.value() && !isLoading.value() }
    .flatMapLatest { plubbingID, cursorID in
        isLoading.onNext(true)
        return FeedsService.shared.fetchBoards(
          plubbingID: plubbingID,
          nextCursorID: cursorID
        )
    }
    
    fetchingBoards.subscribe(onNext: { boards in
      let boardModels = boards.content.map { $0.toBoardModel }
      fetchingBoardModel.accept(boardModels)
      isLoading.onNext(false)
      isLastPage.onNext(boards.isLast)
    })
    .disposed(by: disposeBag)
    
    let fetchingClipboards = selectingPlubbingID
      .flatMapLatest { plubbingID in
        return FeedsService.shared.fetchClipboards(plubbingID: plubbingID)
      }
    
    fetchingClipboards.subscribe(onNext: { contents in
      let mainPageClipboardViewModel = contents.pinnedFeedList.map {
        return MainPageClipboardViewModel(
          type: $0.type,
          contentImageString: $0.feedImageURL,
          contentText: $0.content
        )
      }
      fetchingMainpageClipboardViewModel.accept(mainPageClipboardViewModel)
    })
    .disposed(by: disposeBag)
    
    let requestPinFeed = selectingFix.withLatestFrom(
      Observable.zip(
        selectingPlubbingID,
        selectingFeedID
      )
    )
      .flatMapLatest(FeedsService.shared.pinFeed)
    
    let requestDeleteFeed = selectingDelete.withLatestFrom(
      Observable.zip(
        selectingPlubbingID,
        selectingFeedID
      )
    )
      .flatMapLatest(FeedsService.shared.deleteFeed)
      .map { _ in Void() }
    
    fetchingMoreDatas.withLatestFrom(currentCursorID)
      .filter({ page in
        try isLastPage.value() || isLoading.value() ? false : true
      })
      .map { $0 + 1 }
      .bind(to: currentCursorID)
      .disposed(by: disposeBag)
    
    // Output
    fetchedMainpageClipboardViewModel = fetchingMainpageClipboardViewModel.asDriver(onErrorDriveWith: .empty())
    
    clipboardListIsEmpty = fetchingMainpageClipboardViewModel
      .map { $0.isEmpty }
      .asDriver(onErrorDriveWith: .empty())
    
    fetchedBoardModel = fetchingBoardModel
      .asDriver(onErrorDriveWith: .empty())
    
    isPinnedFeed = requestPinFeed
      .map { $0.feedID }
      .asDriver(onErrorDriveWith: .empty())
    
    successDeleteFeed = requestDeleteFeed.asDriver(onErrorDriveWith: .empty())
  }
  
}

struct MockModel {
  let type: PostType
  let viewType: ViewType
  let content: String
  let feedImageURL: String?
}
