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
  
  /// 댓글 정보 모델입니다.
  ///
  /// 댓글 순서는 작성 날짜를 기준으로 정렬되어있습니다.
  /// 답글은 댓글 사이에 들어갈 수도 있으며, 부모 댓글 다음에 존재하게 됩니다.
  private(set) var comments: [CommentContent] = [] {
    didSet {
      updateSnapshots()
    }
  }
  
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
    
    // 첫 세팅 작업
    Observable.combineLatest(collectionViewSubject.asObservable(), commentsObservable) {
      return (collectionView: $0, commentsData: $1)
    }
    .take(1)  // 첫 세팅 작업이니만큼 한 번만 실행되어야 합니다.
    .subscribe(with: self) { owner, tuple in
      owner.isLast = tuple.commentsData.isLast
      owner.comments.append(contentsOf: tuple.commentsData.content)
      owner.setCollectionView(tuple.collectionView)
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
      }
      .disposed(by: disposeBag)
    
    // == paging part ==
    bottomCellSubject
      .filter { [weak self] in // 마지막으로부터 5번째 이전 셀인지 확인
        guard let self, let dataSource = self.dataSource else {
          return false
        }
        let snapshot = dataSource.snapshot()
        let sectionIdentifier = snapshot.sectionIdentifiers[$0.section]
        let item = snapshot.itemIdentifiers(inSection: sectionIdentifier)[$0.item]
        let index = snapshot.itemIdentifiers.firstIndex(of: item)!
        return snapshot.itemIdentifiers.count - index <= 5
      }
      .filter { [weak self] _ in // 이미 가져오고 있는 중인지 확인
        return self?.isFetching == false
      }
      .do(onNext: { [weak self] _ in
        self?.isFetching = true
      })
      .filter { [weak self] _ in // 호출 가능 여부 판단
        self?.isLast == false
      }
      .flatMap { [weak self] _ in
        return FeedsService.shared.fetchComments(plubbingID: plubbingID, feedID: content.feedID, nextCursorID: self?.comments.last?.commentID ?? 0)
          .compactMap { result -> FeedsPaginatedDataResponse<CommentContent>? in
            // TODO: 승현 - API 통신 에러 처리
            guard case let .success(response) = result else { return nil }
            return response.data
          }
      }
      .subscribe(with: self) { owner, paginatedData in
        owner.isLast = paginatedData.isLast
        owner.comments.append(contentsOf: paginatedData.content)
        owner.isFetching = false
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
  
  /// comments의 내용이 변경되면, 변경점을 인지하고 snapshot을 재설정합니다.
  /// comments 프로퍼티가 변경되면 자동으로 호출되는 `didSet method` 입니다. 추가로 호출할 필요가 없습니다.
  private func updateSnapshots() {
    guard let dataSource else { return }
    
    var snapshot = dataSource.snapshot()
    let sections = snapshot.sectionIdentifiers
    let items = snapshot.itemIdentifiers // 전체 Item을 가져옴
    
    // snapshot에 적용되지 않은 item 선별
    for content in comments where items.contains(content) == false {
      // 댓글인 경우
      if sections.contains(content.groupID) == false {
        snapshot.appendSections([content.groupID])
      }
      snapshot.appendItems([content], toSection: content.groupID)
    }
    
    dataSource.apply(snapshot)
  }
}
