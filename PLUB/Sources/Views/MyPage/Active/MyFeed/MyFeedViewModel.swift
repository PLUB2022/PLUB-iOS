//
//  MyFeedViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/05/14.
//

import UIKit

import RxSwift
import RxCocoa

protocol MyFeedViewModelType {
  // MARK: Property
  var plubbingID: Int { get }
  var plubbingTitle: String { get }
  var feedList: [FeedsContent] { get }
  
  // MARK: Input
  var offsetObserver: AnyObserver<(tableViewHeight: CGFloat, offset: CGFloat)> { get }
  
  // MARK: Output
  var reloadTaleViewDriver: Driver<Void> { get } // 테이블 뷰 리로드
}

final class MyFeedViewModel {
  private let disposeBag = DisposeBag()
  
  // MARK: Property
  private(set) var plubbingID: Int
  private(set) var plubbingTitle: String
  private(set) var feedList = [FeedsContent]()
  private let pagingManager = PagingManager<FeedsContent>(threshold: 700)
  
  // MARK: UseCase
  private let inquireMyFeedUseCase: InquireMyFeedUseCase
  
  // MARK: Subjects
  private let offsetSubject = PublishSubject<(tableViewHeight: CGFloat, offset: CGFloat)>()
  private let reloadTaleViewSubject = PublishSubject<Void>()
  
  init(
    plubbingID: Int,
    plubbingTitle: String,
    inquireMyFeedUseCase: InquireMyFeedUseCase
  ) {
    self.plubbingID = plubbingID
    self.plubbingTitle = plubbingTitle
    self.inquireMyFeedUseCase = inquireMyFeedUseCase
    
    pagingSetup(plubbingID: plubbingID)
  }
  
  private func pagingSetup(plubbingID: Int) {
    offsetSubject
      .filter { [pagingManager] in
        return pagingManager.shouldFetchNextPage(totalHeight: $0, offset: $1)
      }
      .flatMap { [weak self] _ -> Observable<[FeedsContent]> in
        guard let self else { return .empty() }
        return self.pagingManager.fetchNextPage { cursorID in
          self.inquireMyFeedUseCase.execute(plubbingID: plubbingID, cursorID: cursorID)
            .map { data in
              (
                content: data.feedInfo.feedList,
                nextCursorID: data.feedInfo.feedList.last?.feedID ?? 0,
                isLast: data.feedInfo.isLast
              )
            }
        }
      }
      .subscribe(with: self) { owner, content in
        owner.feedList.append(contentsOf: content)
        owner.reloadTaleViewSubject.onNext(())
      }
      .disposed(by: disposeBag)
  }
}

extension MyFeedViewModel: MyFeedViewModelType {
  // MARK: Input
  var offsetObserver: AnyObserver<(tableViewHeight: CGFloat, offset: CGFloat)> {
    offsetSubject.asObserver()
  }
  
  // MARK: Output
  var reloadTaleViewDriver: Driver<Void> { reloadTaleViewSubject.asDriver(onErrorDriveWith: .empty())
  }
}
