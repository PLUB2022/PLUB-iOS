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
  var offsetObserver: AnyObserver<(collectionViewHeight: CGFloat, offset: CGFloat)> { get }
  
  /// 사용자의 댓글을 입력합니다.
  var commentsInput: AnyObserver<String> { get }
  
  /// 답장할 대상자의 ID를 emit합니다.
  var replyIDObserver: AnyObserver<Int?> { get }
  
  /// 삭제 버튼을 누른 경우 해당 옵저버를 이용하여 emit합니다.
  var deleteOptionObserver: AnyObserver<Void> { get }
  
  /// 수정 버튼을 누른 경우 해당 옵저버를 이용하여 emit합니다.
  var editOptionObserver: AnyObserver<Void> { get }
  
  //Output
  
  /// decoratorView에 들어갈 적절한 text를 처리합니다.
  var decoratorNameObserable: Observable<(labelText: String, buttonText: String)> { get }
  
  var showBottomSheetObservable: Observable<CommentOptionBottomSheetViewController.UserAccessType> { get }
}

protocol BoardDetailDataStore {
  var content: BoardModel { get }
  var comments: [CommentContent] { get }
}

final class BoardDetailViewModel: BoardDetailDataStore {
  
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
  
  /// 페이징 관리 객체
  private let pagingManager = PagingManager<CommentContent>(threshold: 700)
  
  // MARK: Use Cases
  
  private let getCommentsUseCase: GetCommentsUseCase
  private let postCommentUseCase: PostCommentUseCase
  private let deleteCommentUseCase: DeleteCommentUseCase
  
  // MARK: Subjects
  
  private let collectionViewSubject           = PublishSubject<UICollectionView>()
  private let commentInputSubject             = PublishSubject<String>()
  private let replyIDSubject                  = BehaviorSubject<Int?>(value: nil)
  private let decoratorNameSubject            = PublishSubject<(labelText: String, buttonText: String)>()
  private let bottomCellSubject               = PublishSubject<(collectionViewHeight: CGFloat, offset: CGFloat)>()
  private let showBottomSheetSubject          = PublishSubject<CommentOptionBottomSheetViewController.UserAccessType>()
  private let recentSelectedCommentIDSubject  = ReplaySubject<Int>.create(bufferSize: 1)
  private let deleteOptionSubject             = PublishSubject<Void>()
  private let editOptionSubject               = PublishSubject<Void>()
  
  // MARK: - Initializations
  
  init(
    plubbingID: Int,
    content: BoardModel,
    getCommentsUseCase: GetCommentsUseCase,
    postCommentUseCase: PostCommentUseCase,
    deleteCommentUseCase: DeleteCommentUseCase
  ) {
    self.content = content
    self.getCommentsUseCase   = getCommentsUseCase
    self.postCommentUseCase   = postCommentUseCase
    self.deleteCommentUseCase = deleteCommentUseCase
    
    fetchComments(plubbingID: plubbingID, content: content)
    createComments(plubbingID: plubbingID, content: content)
    pagingSetup(plubbingID: plubbingID, content: content)
    deleteComments(plubbingID: plubbingID, content: content)
  }
  
  private let disposeBag = DisposeBag()
}

// MARK: - Binding Methods

extension BoardDetailViewModel {
  
  /// 댓글 정보를 가져와 초기 상태의 UI를 업데이트합니다.
  /// - Parameters:
  ///   - plubbingID: 플러빙 ID
  ///   - content: 게시글 컨텐츠 모델
  ///   - collectionViewObservable: 게시글 UI에 사용되는 CollectionView Observable
  private func fetchComments(plubbingID: Int, content: BoardModel) {
    
    // PagingManager를 이용하여 댓글을 가져옴
    let commentsObservable = pagingManager.fetchNextPage { [getCommentsUseCase] cursorID in
      getCommentsUseCase.execute(plubbingID: plubbingID, feedID: content.feedID, nextCursorID: cursorID)
    }
    
    // 첫 세팅 작업
    Observable.combineLatest(collectionViewSubject, commentsObservable) {
      return (collectionView: $0, comments: $1)
    }
    .take(1)  // 첫 세팅 작업이니만큼 한 번만 실행되어야 합니다.
    .subscribe(with: self) { owner, tuple in
      owner.comments.append(contentsOf: tuple.comments)
      owner.setCollectionView(tuple.collectionView)
      owner.applyInitialSnapshots()
    }
    .disposed(by: disposeBag)
  }
  
  /// 입력된 글을 가지고 댓글을 작성합니다.
  /// - Parameters:
  ///   - plubbingID: 플러빙 ID
  ///   - content: 게시글 컨텐츠 모델
  ///   - commentsObservable: 작성된 문자열과 부모 ID를 갖는 Observable
  private func createComments(plubbingID: Int, content: BoardModel) {
    commentInputSubject
      .withLatestFrom(replyIDSubject) { comment, parentID in
        (comment: comment, parentID: parentID)
      }
      .flatMap { [postCommentUseCase] in
        postCommentUseCase.execute(plubbingID: plubbingID, feedID: content.feedID, context: $0.comment, commentParentID: $0.parentID)
      }
      .filter { [weak self] _ in
        return self?.pagingManager.isLast ?? false
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
  }
  
  /// `BoardDetailViewModel`에 대한 페이징 메커니즘을 설정합니다.
  ///
  /// 이 메서드는 `bottomCellSubject`를 관찰하여 페이징 동작을 설정합니다. 현재 아이템이 댓글 목록 끝에서 지정된 임계값 이내인지 확인합니다.
  /// 조건이 충족되고 다음 페이지를 가져올 수 있을 때, `fetchComments API`를 사용하여 다음 페이지를 가져옵니다.
  ///
  /// - Parameters:
  ///   - plubbingID: 플러빙 ID
  ///   - content: 게시글 컨텐츠 모델
  ///   - indexPathObservable: 컬렉션 뷰에서 하단 셀의 인덱스 경로를 전달받는 `Observable`
  private func pagingSetup(plubbingID: Int, content: BoardModel) {
    bottomCellSubject
      .filter { [pagingManager] in // pagingManager에게 fetching 가능한지 요청
        return pagingManager.shouldFetchNextPage(totalHeight: $0, offset: $1)
      }
      .flatMap { [weak self] _ -> Observable<[CommentContent]> in
        guard let self else { return .empty() }
        return self.pagingManager.fetchNextPage { cursorID in
          self.getCommentsUseCase.execute(plubbingID: plubbingID, feedID: content.feedID, nextCursorID: cursorID)
        }
      }
      .subscribe(with: self) { owner, content in
        owner.comments.append(contentsOf: content)
      }
      .disposed(by: disposeBag)
  }
  
  /// 댓글 삭제 관련 파이프라인을 설정합니다.
  /// - Parameters:
  ///   - plubbingID: 플러빙 ID
  ///   - content: 게시글 컨텐츠 모델
  private func deleteComments(plubbingID: Int, content: BoardModel) {
    deleteOptionSubject
      .withLatestFrom(recentSelectedCommentIDSubject)
      .flatMap { [deleteCommentUseCase] commentID in
        deleteCommentUseCase.execute(plubbingID: plubbingID, feedID: content.feedID, commentID: commentID)
      }
      .withLatestFrom(recentSelectedCommentIDSubject)
      .subscribe(with: self) { owner, commentID in
        guard let content = owner.comments.first(where: { $0.commentID == commentID }) else { return }
        if content.type == .normal {
          owner.comments.removeAll {
            $0.groupID == content.groupID
          }
        } else {
          owner.comments.removeAll {
            $0.commentID == content.commentID
          }
        }
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - BoardDetailViewModelType

extension BoardDetailViewModel: BoardDetailViewModelType {
  // Input
  var setCollectionViewObserver: AnyObserver<UICollectionView> {
    collectionViewSubject.asObserver()
  }
  var commentsInput: AnyObserver<String> {
    commentInputSubject.asObserver()
  }
  var offsetObserver: AnyObserver<(collectionViewHeight: CGFloat, offset: CGFloat)> {
    bottomCellSubject.asObserver()
  }
  var replyIDObserver: AnyObserver<Int?> {
    replyIDSubject.asObserver()
  }
  var decoratorNameObserable: Observable<(labelText: String, buttonText: String)> {
    decoratorNameSubject.asObservable()
  }
  var showBottomSheetObservable: Observable<CommentOptionBottomSheetViewController.UserAccessType> {
    showBottomSheetSubject.asObservable()
  }
  var deleteOptionObserver: AnyObserver<Void> {
    deleteOptionSubject.asObserver()
  }
  var editOptionObserver: AnyObserver<Void> {
    editOptionSubject.asObserver()
  }
}

// MARK: - Diffable DataSource

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
      cell.delegate = self
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
    
    var sections = [Constants.boardSection] // 최소한 하나의 Section이라도 존재해야 함
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
    
    // 삭제해야할 section 조회
    let commentsGroupIDs = Set(comments.map(\.groupID)).union([Constants.boardSection])
    let sectionsToRemove = snapshot.sectionIdentifiers.filter { !commentsGroupIDs.contains($0) }
    snapshot.deleteSections(sectionsToRemove)
    
    // snapshot에서 삭제해야할 아이템 조회
    let itemsToRemove = snapshot.itemIdentifiers.filter { !comments.contains($0) }
    snapshot.deleteItems(itemsToRemove)
    
    
    let items = snapshot.itemIdentifiers // 전체 Item을 가져옴
    
    // snapshot에 추가해야할 item 선별
    for content in comments where items.contains(content) == false {
      // 댓글인 경우
      if snapshot.sectionIdentifiers.contains(content.groupID) == false {
        snapshot.appendSections([content.groupID])
      }
      snapshot.appendItems([content], toSection: content.groupID)
    }
    
    dataSource.apply(snapshot)
  }
}

// MARK: - BoardDetailCollectionViewCellDelegate

extension BoardDetailViewModel: BoardDetailCollectionViewCellDelegate {
  func didTappedReplyButton(commentID: Int) {
    guard let commentValue = comments.first(where: { $0.commentID == commentID })
    else {
      return
    }
    decoratorNameSubject.onNext((labelText: "\(commentValue.nickname)에게 답글 쓰는 중...", buttonText: "답글 작성 취소"))
    replyIDSubject.onNext(commentID)
  }
  
  func didTappedOptionButton(commentID: Int) {
    guard let content = comments.first(where: { $0.commentID == commentID })
    else {
      return
    }
    
    // 옵션 버튼을 선택한 셀의 commentID를 emit
    recentSelectedCommentIDSubject.onNext(commentID)
    
    let accessType: CommentOptionBottomSheetViewController.UserAccessType
    
    if content.isCommentAuthor {
      accessType = .`self`
    } else if content.isCurrentUserFeedAuthor {
      accessType = .author
    } else {
      accessType = .normal
    }
    
    showBottomSheetSubject.onNext(accessType)
  }
}

// MARK: - Constants

private extension BoardDetailViewModel {
  enum Constants {
    static let boardSection = -1
  }
}
