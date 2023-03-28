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
  var setCollectionViewObserver: AnyObserver<UICollectionView> { get }
  
  /// 사용자의 댓글을 입력합니다.
  var commentsInput: AnyObserver<String> { get }
}

protocol BoardDetailDataStore {
  var content: BoardModel { get }
  var comments: [CommentContent] { get }
  
  /// 게시글, 댓글에 대한 CollectionViewDiffableDataSource
  var dataSource: BoardDetailViewModel.DataSource? { get }
}

final class BoardDetailViewModel: BoardDetailViewModelType, BoardDetailDataStore {
  
  // Input
  let setCollectionViewObserver: AnyObserver<UICollectionView>
  let commentsInput: AnyObserver<String>
  
  // MARK: - Properties
  
  let content: BoardModel
  var comments: [CommentContent] = []
  
  private(set) var dataSource: DataSource?
  
  // MARK: - Initializations
  
  init(plubbingID: Int, content: BoardModel) {
    self.content = content
    
    let collectionViewSubject = PublishSubject<UICollectionView>()
    let commentInputSubject   = PublishSubject<String>()
    
    setCollectionViewObserver = collectionViewSubject.asObserver()
    commentsInput = commentInputSubject.asObserver()
    
    // == fetching comments part ==
    let commentsObservable = FeedsService.shared.fetchComments(plubbingID: plubbingID, feedID: content.feedID, nextCursorID: comments.last?.commentID ?? 0)
      .compactMap { result -> FeedsPaginatedDataResponse<CommentContent>? in
        // TODO: 승현 - API 통신 에러 처리
        guard case let .success(response) = result else { return nil }
        return response.data
      }
      .filter { [weak self] in $0.isLast == false || self?.comments.count == 0 }
      .map { $0.content }
    
    Observable.combineLatest(collectionViewSubject.asObservable(), commentsObservable)
      .subscribe(with: self) { owner, tuple in
        owner.comments.append(contentsOf: tuple.1)
        owner.setCollectionView(tuple.0)
        owner.applyInitialSnapshots()
      }
      .disposed(by: disposeBag)
  }
  
  private let disposeBag = DisposeBag()
}

extension BoardDetailViewModel {
  
  // MARK: Type Alias
  
  typealias Section = Int
  typealias Item = CommentContent
  typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
  
  typealias CellRegistration = UICollectionView.CellRegistration<BoardDetailCollectionViewCell, CommentContent>
  typealias HeaderRegistration = UICollectionView.SupplementaryRegistration<BoardDetailCollectionHeaderView>
  
  // MARK: Snapshot & DataSource Part
  
  /// Collection View를 세팅하며, `DiffableDataSource`를 초기화하여 해당 Collection View에 데이터를 지닌 셀을 처리합니다.
  private func setCollectionView(_ collectionView: UICollectionView) {
    
    // 단어 그대로 `등록`처리 코드, 셀 후처리할 때 사용됨
    let registration = CellRegistration { cell, _, item in
      cell.configure(with: item)
    }
    
    // Header View Registration, 헤더 뷰 후처리에 사용됨
    let headerRegistration = HeaderRegistration(elementKind: UICollectionView.elementKindSectionHeader) { [content] supplementaryView, elementKind, indexPath in
      supplementaryView.configure(with: content)
    }
    
    // dataSource에 cell 등록
    dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
      return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
    }
    
    // dataSource에 headerView도 등록
    dataSource?.supplementaryViewProvider = .init { collectionView, elementKind, indexPath in
      return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
    }
  }
  
  /// 초기 Snapshot을 설정합니다. DataSource가 초기화될 시 해당 메서드가 실행됩니다.
  /// 직접 이 메서드를 실행할 필요는 없습니다.
  private func applyInitialSnapshots() {
    var snapshot = Snapshot()
    
    var sections = [-1] // 최소한 하나의 Section이라도 존재해야 함
    sections.append(contentsOf: Array(Set(comments.map { $0.groupID })).sorted())
    snapshot.appendSections(sections)
    
    sections.forEach { sectionGroupID in
      snapshot.appendItems(comments.filter { $0.groupID == sectionGroupID }, toSection: sectionGroupID)
    }
    dataSource?.apply(snapshot)
  }
}
