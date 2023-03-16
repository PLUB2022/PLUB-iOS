//
//  BoardDetailViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/03/06.
//

import UIKit

import RxSwift
import RxCocoa

protocol BoardDetailViewModelType {
  // Input
  
  // Output
  var fetchAlertDriver: Driver<Void> { get }
}

protocol BoardDetailDataStore {
  var content: FeedsContent { get }
  var comments: [CommentContent] { get }
}

final class BoardDetailViewModel: BoardDetailViewModelType, BoardDetailDataStore {
  
  // Output
  let fetchAlertDriver: Driver<Void>
  
  // MARK: - Properties
  
  let content: FeedsContent
  var comments: [CommentContent] = []
  
  private let requestCommentsSubject = PublishSubject<Void>()
  
  // MARK: - Initializations
  
  init(content: FeedsContent) {
    self.content = content
    
    fetchAlertDriver = requestCommentsSubject.asDriver(onErrorDriveWith: .empty())
    bind()
  }
  
  private func bind() {
    FeedsService.shared.fetchComments(plubbingID: content.plubbingID!, feedID: content.feedID, nextCursorID: comments.last?.commentID ?? 0)
      .compactMap { result -> FeedsPaginatedDataResponse<CommentContent>? in
        // TODO: 승현 - API 통신 에러 처리
        guard case let .success(response) = result else { return nil }
        return response.data
      }
      .filter { [weak self] in $0.isLast == false || self?.comments.count == 0 }
      .map { $0.content }
      .subscribe(with: self) { owner, model in
        owner.comments.append(contentsOf: model)
        owner.requestCommentsSubject.onNext(Void()) // content, comments가 전부 할당되었으므로 onNext로 알림
      }
      .disposed(by: disposeBag)
  }
  
  private let disposeBag = DisposeBag()
}
