//
//  BoardDetailViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/03/06.
//

import UIKit

import RxSwift
import RxCocoa

protocol BoardDetailViewModelType: BoardDetailViewModel {
  
  // Input
  
  /// ViewController 단에서 initialized된 collectionView를 받습니다.
  var setCollectionViewObserver: AnyObserver<UICollectionView> { get }
  
  /// 보여지는 댓글 Cell 중 제일 밑의 셀의 IndexPath를 받습니다.
  var offsetObserver: AnyObserver<(collectionViewHeight: CGFloat, offset: CGFloat)> { get }
  
  /// 사용자의 댓글을 입력합니다.
  var commentsInput: AnyObserver<String> { get }
  
  /// 댓(답)글, 댓글 수정 작업을 처리할 대상자의 ID를 emit합니다.
  var targetIDObserver: AnyObserver<Int?> { get }
  
  /// 삭제할 댓글의 ID를 emit합니다.
  var deleteIDObserver: AnyObserver<Int> { get }
  
  /// 댓(답)글, 댓글 수정, 댓글 삭제의 옵션을 처리할 경우 해당 옵저버를 이용합니다.
  var commentOptionObserver: AnyObserver<CommentOption> { get }
  
  //Output
  
  /// 수정할 댓글의 정보를 전달합니다.
  var editCommentTextObservable: Observable<String> { get }
  
  /// decoratorView에 들어갈 적절한 text를 처리합니다.
  var decoratorNameObserable: Observable<(labelText: String, buttonText: String)> { get }
  
  var showBottomSheetObservable: Observable<(commentID: Int, userType: CommentOptionBottomSheetViewController.UserAccessType)> { get }
}

protocol BoardDetailDataStore {
  var content: BoardModel { get }
  var comments: Set<CommentContent> { get }
}

final class BoardDetailViewModel: BoardDetailDataStore {
  
  // MARK: - Properties
  
  let content: BoardModel
  
  /// 댓글 정보 모델입니다.
  ///
  /// 댓글 순서는 작성 날짜를 기준으로 정렬되어있습니다.
  /// 답글은 댓글 사이에 들어갈 수도 있으며, 부모 댓글 다음에 존재하게 됩니다.
  private(set) var comments: Set<CommentContent> = [] {
    didSet {
      updateSnapshots(oldComments: oldValue)
    }
  }
  
  /// 게시글, 댓글에 대한 CollectionViewDiffableDataSource
  private var dataSource: DataSource?
  
  /// 페이징 관리 객체
  private let pagingManager = PagingManager<CommentContent>(threshold: 700)
  
  // MARK: Use Cases
  
  private let getFeedDetailUseCase: GetFeedDetailUseCase
  private let getCommentsUseCase: GetCommentsUseCase
  private let postCommentUseCase: PostCommentUseCase
  private let deleteCommentUseCase: DeleteCommentUseCase
  private let editCommentUseCase: EditCommentUseCase
  private let likeFeedUseCase: LikeFeedUseCase
  
  // MARK: Subjects
  
  private let collectionViewSubject           = PublishSubject<UICollectionView>()
  private let commentInputSubject             = PublishSubject<String>()
  private let editCommentTextSubject          = PublishSubject<String>()
  private let decoratorNameSubject            = PublishSubject<(labelText: String, buttonText: String)>()
  private let bottomCellSubject               = PublishSubject<(collectionViewHeight: CGFloat, offset: CGFloat)>()
  private let showBottomSheetSubject          = PublishSubject<(commentID: Int, userType: CommentOptionBottomSheetViewController.UserAccessType)>()
  private let targetIDSubject                 = BehaviorSubject<Int?>(value: nil)
  private let deleteIDSubject                 = PublishSubject<Int>()
  private let commentOptionSubject            = BehaviorSubject<CommentOption>(value: .commentOrReply)
  
  // MARK: - Initializations
  
  init(
    plubbingID: Int,
    content: BoardModel,
    getFeedDetailUseCase: GetFeedDetailUseCase,
    getCommentsUseCase: GetCommentsUseCase,
    postCommentUseCase: PostCommentUseCase,
    deleteCommentUseCase: DeleteCommentUseCase,
    editCommentUseCase: EditCommentUseCase,
    likeFeedUseCase: LikeFeedUseCase
  ) {
    self.content = content
    self.getFeedDetailUseCase = getFeedDetailUseCase
    self.getCommentsUseCase   = getCommentsUseCase
    self.postCommentUseCase   = postCommentUseCase
    self.deleteCommentUseCase = deleteCommentUseCase
    self.editCommentUseCase   = editCommentUseCase
    self.likeFeedUseCase      = likeFeedUseCase
    
    fetchComments(plubbingID: plubbingID, content: content)
    createComments(plubbingID: plubbingID, content: content)
    pagingSetup(plubbingID: plubbingID, content: content)
    deleteComments(plubbingID: plubbingID, content: content)
    editComments(plubbingID: plubbingID, content: content)
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
      owner.comments.formUnion(tuple.comments) // 댓글 삽입
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
      .filter { [commentOptionSubject] _ in
        let value = try? commentOptionSubject.value()
        return value == .commentOrReply
      }
      .withLatestFrom(targetIDSubject) { comment, parentID in
        (comment: comment, parentID: parentID)
      }
      .flatMap { [postCommentUseCase] in
        postCommentUseCase.execute(plubbingID: plubbingID, feedID: content.feedID, context: $0.comment, commentParentID: $0.parentID)
      }
      .filter { [weak self] _ in
        return self?.pagingManager.isLast ?? false
      }
      .do(onNext: { [weak self] _ in  // API 호출을 위해 작업한 targetID와 commentOption을 기본값으로 초기화
        self?.targetIDSubject.onNext(nil)
        self?.commentOptionSubject.onNext(.commentOrReply)
      })
      .subscribe(with: self) { owner, comment in
        owner.comments.insert(comment) // 댓글 삽입
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
      .subscribe(with: self) { owner, contents in
        owner.comments.formUnion(contents) // 기존 댓글과 새롭게 받은 댓글을 합집합 연산으로 합침
      }
      .disposed(by: disposeBag)
  }
  
  /// 댓글 삭제 관련 파이프라인을 설정합니다.
  /// - Parameters:
  ///   - plubbingID: 플러빙 ID
  ///   - content: 게시글 컨텐츠 모델
  private func deleteComments(plubbingID: Int, content: BoardModel) {
    deleteIDSubject
      .flatMap { [deleteCommentUseCase] commentID in
        deleteCommentUseCase.execute(commentID: commentID)
      }
      .withLatestFrom(deleteIDSubject)
      .subscribe(with: self) { owner, commentID in
        guard let content = owner.comments.first(where: { $0.commentID == commentID }) else { return }
        // 차집합으로 자신과 자식 댓글까지 제거
        owner.comments.subtract(owner.comments.filter { $0.parentCommentID == content.commentID || $0 == content })
      }
      .disposed(by: disposeBag)
  }
  
  /// 댓글 수정 관련 파이프라인을 설정합니다.
  private func editComments(plubbingID: Int, content: BoardModel) {
    let editOption = commentOptionSubject.filter { $0 == .edit }.share()
    
    // 댓글 수정 시 decorator view의 label과 button 텍스트 수정
    editOption
      .map { _ in (labelText: "댓글 수정 중...", buttonText: "취소") }
      .bind(to: decoratorNameSubject)
      .disposed(by: disposeBag)
    
    // 댓글 수정 시 댓글작성란에 수정해야할 텍스트를 emit
    editOption
      .withLatestFrom(targetIDSubject)
      .compactMap { [weak self] commentID in
        self?.comments.first(where: { $0.commentID == commentID })?.content
      }
      .bind(to: editCommentTextSubject)
      .disposed(by: disposeBag)
    
    // 댓글 수정 로직 시나리오
    commentInputSubject
      .filter { [commentOptionSubject] _ in
        let value = try? commentOptionSubject.value()
        return value == .edit
      }
      .withLatestFrom(targetIDSubject) {
        (comment: $0, targetID: $1)
      }
      .compactMap { comment, targetID -> (comment: String, targetID: Int)? in
        guard let targetID else { return nil }
        return (comment: comment, targetID: targetID)
      }
      .flatMap { [editCommentUseCase] in
        editCommentUseCase.execute(plubbingID: plubbingID, feedID: content.feedID, commentID: $0.targetID, content: $0.comment)
      }
      .do(onNext: { [weak self] _ in
        self?.targetIDSubject.onNext(nil)
        self?.commentOptionSubject.onNext(.commentOrReply)
      })
      .subscribe(with: self) { owner, comment in
        guard let value = owner.comments.first(where: { $0.commentID == comment.commentID })
        else {
          return
        }
        // 배타적 논리합으로 기존 댓글을 제거하고 수정된 댓글을 추가
        owner.comments.formSymmetricDifference([value, comment])
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
  
  var targetIDObserver: AnyObserver<Int?> {
    targetIDSubject.asObserver()
  }
  
  var deleteIDObserver: AnyObserver<Int> {
    deleteIDSubject.asObserver()
  }
  
  var commentOptionObserver: AnyObserver<CommentOption> {
    commentOptionSubject.asObserver()
  }
  
  // Output
  
  var editCommentTextObservable: Observable<String> {
    editCommentTextSubject.asObservable()
  }
  
  var decoratorNameObserable: Observable<(labelText: String, buttonText: String)> {
    decoratorNameSubject.asObservable()
  }
  
  var showBottomSheetObservable: Observable<(commentID: Int, userType: CommentOptionBottomSheetViewController.UserAccessType)> {
    showBottomSheetSubject.asObservable()
  }
}

// MARK: - Diffable DataSource

extension BoardDetailViewModel {
  
  // MARK: Type Alias
  
  typealias Section = Int
  typealias Item = Int
  typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
  
  typealias CellRegistration = UICollectionView.CellRegistration<BoardDetailCollectionViewCell, Int>
  typealias HeaderRegistration = UICollectionView.SupplementaryRegistration<BoardDetailCollectionHeaderView>
  
  // MARK: Snapshot & DataSource Part
  
  /// Collection View를 세팅하며, `DiffableDataSource`를 초기화하여 해당 Collection View에 데이터를 지닌 셀을 처리합니다.
  private func setCollectionView(_ collectionView: UICollectionView) {
    
    // 단어 그대로 `등록`처리 코드, 셀 후처리할 때 사용됨
    let registration = CellRegistration { cell, indexPath, id in
      let recentItem = self.comments.first(where: { $0.commentID == id })!
      cell.configure(with: recentItem)
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
      snapshot.appendItems(comments.filter({ $0.groupID == sectionGroupID }).map(\.commentID).sorted(), toSection: sectionGroupID)
    }
    dataSource?.apply(snapshot)
  }
  
  /// comments의 내용이 변경되면, 변경점을 인지하고 snapshot을 재설정합니다.
  /// comments 프로퍼티가 변경되면 자동으로 호출되는 `didSet method` 입니다. 추가로 호출할 필요가 없습니다.
  private func updateSnapshots(oldComments: Set<CommentContent>) {
    guard let dataSource else { return }
    
    var snapshot = dataSource.snapshot()
    
    // 삭제해야할 section 조회
    let commentsGroupIDs = Set(comments.map(\.groupID)).union([Constants.boardSection])
    let sectionsToRemove = Set(snapshot.sectionIdentifiers).subtracting(commentsGroupIDs)
    snapshot.deleteSections(Array(sectionsToRemove))
    
    // snapshot에서 삭제해야할 아이템 조회
    let commentIDs = Set(comments.map(\.commentID))
    let itemsToRemove = Set(snapshot.itemIdentifiers).subtracting(commentIDs)
    snapshot.deleteItems(Array(itemsToRemove))
    
    // 수정이 필요한 아이템 선별
    let itemsToEdit = oldComments.symmetricDifference(comments).map(\.commentID)
    // 수정한 댓글은 (기존 댓글, 수정된 댓글)이 필터링되어 2개가 나오고, 그 두 개의 commentID값은 서로 같습니다.
    if itemsToEdit.count == 2 && itemsToEdit.first == itemsToEdit.last {
      snapshot.reconfigureItems([itemsToEdit.first!])
    }
    
    // snapshot에 추가해야할 item 선별
    for content in comments.sorted(by: { $0.groupID < $1.groupID || $0.commentID < $1.commentID }) where snapshot.itemIdentifiers.contains(content.commentID) == false {
      // 댓글인 경우
      if snapshot.sectionIdentifiers.contains(content.groupID) == false {
        snapshot.appendSections([content.groupID])
      }
      snapshot.appendItems([content.commentID], toSection: content.groupID)
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
    
    // 현재 작성중인 옵션이 답글임을 명시
    commentOptionSubject.onNext(.commentOrReply)
    decoratorNameSubject.onNext((labelText: "\(commentValue.nickname)에게 답글 쓰는 중...", buttonText: "답글 작성 취소"))
    targetIDSubject.onNext(commentID)
  }
  
  func didTappedOptionButton(commentID: Int) {
    guard let content = comments.first(where: { $0.commentID == commentID })
    else {
      return
    }
    
    let accessType: CommentOptionBottomSheetViewController.UserAccessType
    
    if content.isCommentAuthor {
      accessType = .`self`
    } else if content.isCurrentUserFeedAuthor {
      accessType = .author
    } else {
      accessType = .normal
    }
    
    showBottomSheetSubject.onNext((commentID, accessType))
  }
}

// MARK: - DecoratorOption

extension BoardDetailViewModel {
  /// 댓글 옵션 열거형
  enum CommentOption {
    /// 단순 댓글 및 답글
    case commentOrReply
    
    /// 댓글 수정
    case edit
  }
}

// MARK: - Constants

private extension BoardDetailViewModel {
  enum Constants {
    static let boardSection = -1
  }
}
