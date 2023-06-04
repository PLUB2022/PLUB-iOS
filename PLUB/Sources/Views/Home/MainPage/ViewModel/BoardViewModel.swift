//
//  BoardViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/02.
//

import UIKit

import RxSwift
import RxCocoa
import Foundation

protocol BoardViewModelType {
  // Intput
  var selectPlubbingID: AnyObserver<Int> { get }
  var selectFeedID: AnyObserver<Int> { get }
  var selectFix: AnyObserver<Void> { get }
  var selectModify: AnyObserver<(String, String?, UIImage?)?> { get }
  //  var selectReport: AnyObserver<Void> { get }
  var selectDelete: AnyObserver<Void> { get }
  var fetchMoreDatas: AnyObserver<Void> { get }
  
  // Output
  var fetchedMainpageClipboardViewModel: Driver<[MainPageClipboardViewModel]> { get }
  var fetchedBoardModel: Driver<[BoardModel]> { get }
  var clipboardListIsEmpty: Driver<Bool> { get }
  
  func clearStatus()
  
}

final class BoardViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let selectingPlubbingID = PublishSubject<Int>()
  private let selectingFeedID = PublishSubject<Int>()
  private let selectingFix = PublishSubject<Void>()
  private let selectingDelete = PublishSubject<Void>()
  private let selectingModify = BehaviorSubject<(String, String?, UIImage?)?>(value: nil)
  private let fetchingMainpageClipboardViewModel = BehaviorRelay<[MainPageClipboardViewModel]>(value: [])
  private let fetchingBoardModel = BehaviorRelay<[BoardModel]>(value: [])
  private let fetchingMoreDatas = PublishSubject<Void>()
  private let currentCursorID = BehaviorRelay<Int>(value: 0)
  private let isLastPage = BehaviorSubject<Bool>(value: false)
  private let isLoading = BehaviorSubject<Bool>(value: false)
  private let lastID = BehaviorSubject<Int>(value: 0)
  private let modifyImageString = BehaviorSubject<String?>(value: nil)
  
  init() {
    tryFetchingBoards()
    tryFetchingClipboards()
    tryFetchingMoreDatas()
    tryDeleteBoard()
    tryPinnedBoard()
    tryUpdateBoard()
  }
  
  func clearStatus() {
    isLastPage.onNext(false)
    isLoading.onNext(false)
    fetchingBoardModel.accept([])
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
    
    fetchingBoards
      .subscribe(with: self) { owner, boards in
        guard let feedID = boards.content.last?.feedID else { return }
        var entireModel = owner.fetchingBoardModel.value
        let boardModels = boards.content.map { $0.toBoardModel }
        entireModel.append(contentsOf: boardModels)
        owner.fetchingBoardModel.accept(entireModel)
        owner.isLoading.onNext(false)
        owner.lastID.onNext(feedID)
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
    fetchingMoreDatas
      .withLatestFrom(lastID)
      .withUnretained(self)
      .filter({ owner, _ in
        try !owner.isLastPage.value() && !owner.isLoading.value()
      })
      .subscribe(onNext: { owner, cursorID in
        owner.currentCursorID.accept(cursorID)
      })
      .disposed(by: disposeBag)
  }
  
  private func tryDeleteBoard() {
    let selectingDelete = selectingDelete.share()
    
    selectingDelete.withLatestFrom(
      Observable.combineLatest(
        selectingPlubbingID,
        selectingFeedID
      )
    )
    .flatMapLatest(FeedsService.shared.deleteFeed)
    .map { _ in Void() }
    .subscribe(with: self) { owner, _ in
      Log.debug("해당 게시글을 삭제하였습니다")
    }
    .disposed(by: disposeBag)
    
    selectingDelete.withLatestFrom(selectingFeedID)
      .subscribe(with: self) { owner, feedID in
        let boardModel = owner.fetchingBoardModel.value
        let deleteBoardModel = boardModel.filter { $0.feedID != feedID }
        owner.fetchingBoardModel.accept(deleteBoardModel)
      }
      .disposed(by: disposeBag)
  }
  
  private func tryPinnedBoard() {
    selectingFix.withLatestFrom(
      Observable.combineLatest(selectingPlubbingID, selectingFeedID)
    )
    .flatMapLatest(FeedsService.shared.pinFeed)
    .map { $0.feedID }
    .subscribe(with: self) { owner, feedID in
      var boardModel = owner.fetchingBoardModel.value
      var clipboardModel = owner.fetchingMainpageClipboardViewModel.value
      
      guard let findBoardModel = boardModel.filter({ $0.feedID == feedID }).first else { return }
      boardModel.removeAll(where: { $0.feedID == feedID })
      owner.fetchingBoardModel.accept(boardModel)
      
      let model = MainPageClipboardViewModel(model: findBoardModel)
      clipboardModel.insert(model, at: 0)
      owner.fetchingMainpageClipboardViewModel.accept(clipboardModel)
      Log.debug("피드 아이디\(feedID ) 고정완료하였습니다")
    }
    .disposed(by: disposeBag)
  }
  
  private func setupImageToString(image: UIImage?) -> Observable<String?> {
    guard let image = image else { return .just(nil) }
    let uploadImage = ImageService.shared.uploadImage(
      images: [image],
      params: .init(type: .feed)
    )
    
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
    
    return tryImageToString
  }
  
  private func tryUpdateBoard() {
    selectingModify.compactMap { $0 }
      .withLatestFrom(
      Observable.combineLatest(
        selectingPlubbingID,
        selectingFeedID
      )
    ) { ($0, $1) }
      .withUnretained(self)
      .flatMapLatest { (owner, arg1) -> Observable<BoardsResponse> in
        let (request, result) = arg1
        let (plubbingID, feedID) = result
        let (title, content, feedImage) = request
        return owner.setupImageToString(image: feedImage)
          .flatMap { feedImage in
            print("여기오나\(feedImage)")
          return FeedsService.shared.updateFeed(
            plubbingID: plubbingID,
            feedID: feedID,
            model: BoardsRequest(
              title: title,
              content: content,
              feedImage: feedImage
            )
          )
        }
      }
      .map { $0.feedID }
      .subscribe(with: self) { owner, feedID in
        let boardModel = owner.fetchingBoardModel.value
        guard let tryRequest = try? owner.selectingModify.value() else { return }

//        let updateBoardModel = boardModel.map { model in
//          if model.feedID == feedID {
//            return model.updateBoardModel(request: tryRequest)
//          }
//          return model
//        }

//        owner.fetchingBoardModel.accept(updateBoardModel)
        Log.debug("수정완료하였습니다")
      }
      .disposed(by: disposeBag)
  }
}

extension BoardViewModel: BoardViewModelType {
  
  var selectModify: AnyObserver<(String, String?, UIImage?)?> {
    selectingModify.asObserver()
  }
  
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
      Observable.combineLatest(
        selectingPlubbingID,
        selectingFeedID.do(onNext: { print("피드아이디 들어옴 ? \($0)") })
      )
    )
    .flatMapLatest(FeedsService.shared.pinFeed)
    .map { $0.feedID }
    .asDriver(onErrorDriveWith: .empty())
  }
}
