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
  
  /// ViewController 단에서 initialized된 collectionView를 받습니다.
  var setCollectionViewObserver: AnyObserver<UICollectionView> { get }
  
  /// 보여지는 댓글 Cell 중 제일 밑의 셀의 IndexPath를 받습니다.
  var bottomCellObserver: AnyObserver<IndexPath> { get }
  
  /// 사용자의 댓글을 입력합니다.
  var commentsInput: AnyObserver<(comment: String, parentID: Int?)> { get }
}

protocol BoardDetailDataStore {
  var content: BoardModel { get }
  var comments: [CommentContent] { get }
}

final class BoardDetailViewModel: BoardDetailViewModelType, BoardDetailDataStore {
  
  // Input
  let setCollectionViewObserver: AnyObserver<UICollectionView>
  let commentsInput: AnyObserver<(comment: String, parentID: Int?)>
  let bottomCellObserver: AnyObserver<IndexPath>
  
  // MARK: - Properties
  
  let content: BoardModel
  var comments: [CommentContent] = []
  
  /// 게시글, 댓글에 대한 CollectionViewDiffableDataSource
  private var dataSource: DataSource?
  
  /// 현재 마지막 커서(페이지)인지 판단할 때 사용합니다.
  private var isLast = false
  
  /// API를 요청하는 중인지 확인합니다.
  private var isFetching = false
  
  // MARK: - Initializations
  
  init(plubbingID: Int, content: BoardModel) {
    self.content = content
    
    let collectionViewSubject = PublishSubject<UICollectionView>()
    let commentInputSubject   = PublishSubject<(comment: String, parentID: Int?)>()
    let bottomCellSubject     = PublishSubject<IndexPath>()
    
    setCollectionViewObserver = collectionViewSubject.asObserver()
    commentsInput = commentInputSubject.asObserver()
    bottomCellObserver = bottomCellSubject.asObserver()
    
    // == fetching comments part ==
    let commentsObservable = FeedsService.shared.fetchComments(plubbingID: plubbingID, feedID: content.feedID, nextCursorID: comments.last?.commentID ?? 0)
      .compactMap { result -> FeedsPaginatedDataResponse<CommentContent>? in
        // TODO: 승현 - API 통신 에러 처리
        guard case let .success(response) = result else { return nil }
        return response.data
      }
      .filter { [weak self] in $0.isLast == false || self?.comments.count == 0 }
    
    // 첫 세팅 작업
    Observable.combineLatest(collectionViewSubject.asObservable(), commentsObservable)
      .subscribe(with: self) { owner, tuple in
        owner.isLast = tuple.1.isLast
        owner.comments.append(contentsOf: tuple.1.content)
        owner.setCollectionView(tuple.0)
        owner.applyInitialSnapshots()
      }
      .disposed(by: disposeBag)
    
    // == create comments part ==
    commentInputSubject
      .flatMap { FeedsService.shared.createComments(plubbingID: plubbingID, feedID: content.feedID, comment: $0.comment, commentParentID: $0.parentID) }
      .compactMap { result -> CommentContent? in
        // TODO: 승현 - API 통신 에러 처리
        guard case let .success(response) = result else { return nil }
        return response.data
      }
      .filter { [weak self] _ in
        return self?.isLast ?? false
      }
      .subscribe(with: self) { owner, comment in
        // 일반 댓글은 단순 append
        if comment.type == .normal {
          owner.comments.append(comment)
        } else {
          // 작성된 답글은 마지막 답글 뒤에 insert
          let index = owner.comments.map { $0.groupID }.lastIndex(of: comment.groupID)!
          owner.comments.insert(comment, at: index + 1)
        }
        owner.addCommentToGroup(comment)
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
  
  /// 댓글을 그룹화하여 적용합니다.
  /// - Parameter content: 댓글 또는 답글
  private func addCommentToGroup(_ content: CommentContent) {
    guard let dataSource else { return }
    var snapshot = dataSource.snapshot()
    
    // 일반 댓글인 경우
    if content.type == .normal {
      snapshot.appendSections([content.groupID]) // 섹션을 새롭게 추가
      snapshot.appendItems([content], toSection: content.groupID)
    } else {
      // 답글인 경우
      snapshot.appendItems([content], toSection: content.groupID)
    }
    dataSource.apply(snapshot)
  }
  
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
