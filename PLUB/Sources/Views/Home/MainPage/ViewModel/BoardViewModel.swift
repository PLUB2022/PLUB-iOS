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
  
  // Output
  var fetchedMainpageClipboardViewModel: Driver<[MainPageClipboardViewModel]> { get }
  var fetchedBoardModel: Driver<[BoardModel]> { get }
  var clipboardListIsEmpty: Driver<Bool> { get }
  
}

final class BoardViewModel: BoardViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let selectPlubbingID: AnyObserver<Int>
  
  // Output
  let fetchedMainpageClipboardViewModel: Driver<[MainPageClipboardViewModel]>
  let fetchedBoardModel: Driver<[BoardModel]>
  let clipboardListIsEmpty: Driver<Bool>
  
  init() {
    let selectingPlubbingID = PublishSubject<Int>()
    let fetchingMainpageClipboardViewModel = BehaviorRelay<[MainPageClipboardViewModel]>(value: [])
    let fetchingBoardModel = BehaviorRelay<[BoardModel]>(value: [])
    
    self.selectPlubbingID = selectingPlubbingID.asObserver()
    
    // Input
    let fetchingBoards = selectingPlubbingID
      .flatMapLatest { plubbingID in
        return FeedsService.shared.fetchBoards(plubbingID: plubbingID)
      }
    
    let fetchingClipboards = selectingPlubbingID
      .flatMapLatest { plubbingID in
        return FeedsService.shared.fetchClipboards(plubbingID: plubbingID)
      }
    
    let successFetchingBoards = fetchingBoards.compactMap { result -> [FeedsContent]? in
      guard case .success(let response) = result else { return nil }
      return response.data?.content
    }
    
    successFetchingBoards.subscribe(onNext: { boards in
      let boardModels = boards.map { $0.toBoardModel }
      fetchingBoardModel.accept(boardModels)
    })
    .disposed(by: disposeBag)
    
    let successFetchingClipboards = fetchingClipboards.compactMap { result -> [FeedsContent]? in
      guard case .success(let response) = result else { return nil }
      return response.data?.pinnedFeedList
    }
    
    successFetchingClipboards.subscribe(onNext: { contents in
      let mainPageClipboardViewModel = contents.map {
        return MainPageClipboardViewModel(
          type: $0.type,
          contentImageString: $0.feedImageURL,
          contentText: $0.content
        )
      }
      fetchingMainpageClipboardViewModel.accept(mainPageClipboardViewModel)
    })
    .disposed(by: disposeBag)
    
    // Output
    fetchedMainpageClipboardViewModel = fetchingMainpageClipboardViewModel.asDriver(onErrorDriveWith: .empty())
    
    clipboardListIsEmpty = fetchingMainpageClipboardViewModel
      .map { $0.isEmpty }
      .asDriver(onErrorDriveWith: .empty())
    
    fetchedBoardModel = fetchingBoardModel.asDriver(onErrorDriveWith: .empty())
  }
  
}

struct MockModel {
  let type: PostType
  let viewType: ViewType
  let content: String
  let feedImageURL: String?
}
