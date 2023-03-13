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
  var clipboardListIsEmpty: Driver<Bool> { get }
  
}

/// 게시판에 관련된 클립보드리스트가 존재하는지에 대한 여부 BoardHeaderViewType Output 필요
///  클립보드에 관련된 리스트가 몇개인지에 대한 ClipboardType Output 필요
final class BoardViewModel: BoardViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let selectPlubbingID: AnyObserver<Int>
  
  // Output
  let fetchedMainpageClipboardViewModel: Driver<[MainPageClipboardViewModel]>
  let clipboardListIsEmpty: Driver<Bool>
  
  init() {
    let selectingPlubbingID = PublishSubject<Int>()
    let fetchingMainpageClipboardViewModel = BehaviorRelay<[MainPageClipboardViewModel]>(value: [])
    
    self.selectPlubbingID = selectingPlubbingID.asObserver()
    
    // Input
    let fetchingBoards = selectingPlubbingID
      .flatMapLatest { plubbingID in
        return FeedsService.shared.fetchBoards(plubIdentifier: plubbingID)
      }
    
    let fetchingClipboards = selectingPlubbingID
      .flatMapLatest { plubbingID in
        return FeedsService.shared.fetchClipboards(plubIdentifier: plubbingID)
      }
    
    let successFetchingBoards = fetchingBoards.compactMap { result -> [FeedsContent]? in
      guard case .success(let response) = result else { return nil }
      return response.data?.content
    }
    
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
  }
  
}

struct MockModel {
  let type: PostType
  let viewType: ViewType
  let content: String
  let feedImageURL: String?
}
