//
//  MainPageViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/01.
//

import Foundation

import RxSwift
import RxCocoa

protocol MainPageViewModelType {
  // Input
  var whichPlubID: AnyObserver<Int> { get }
  
  // Output
  var fetchedBoardModel: Driver<[BoardModel]> { get }
}

final class MainPageViewModel: MainPageViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let whichPlubID: AnyObserver<Int>
  
  // Output
  let fetchedBoardModel: Driver<[BoardModel]>
  
  init() {
    let selectingPlubID = PublishSubject<Int>()
    let fetchingBoardModel = BehaviorRelay<[BoardModel]>(value: [])
    
    self.whichPlubID = selectingPlubID.asObserver()
    
    // Input
    let successFetchingFeedContents = selectingPlubID
      .flatMapLatest { FeedsService.shared.fetchBoards(plubbingID: $0) }
      .share()
    
    successFetchingFeedContents
      .subscribe(onNext: { feedContents in
        let boardModels = feedContents.content.map { feedContent in
          BoardModel(
            feedID: feedContent.feedID,
            viewType: feedContent.viewType,
            author: feedContent.nickname,
            authorProfileImageLink: feedContent.profileImageURL,
            date: Date(),
            likeCount: feedContent.likeCount,
            commentCount: feedContent.commentCount,
            title: feedContent.title,
            imageLink: feedContent.feedImageURL,
            content: feedContent.content,
            isPinned: feedContent.isPinned,
            isAuthor: feedContent.isAuthor,
            isHost: feedContent.isHost
          )
        }
        fetchingBoardModel.accept(boardModels)
      })
      .disposed(by: disposeBag)
    
    // Output
    fetchedBoardModel = fetchingBoardModel.asDriver(onErrorJustReturn: [])
  }
}
