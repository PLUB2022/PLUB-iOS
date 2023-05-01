// 
//  ArchiveViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/03/10.
//

import UIKit

import RxSwift
import RxCocoa

protocol ArchiveViewModelType {
  // Input
  
  /// ViewController 단에서 initialized된 collectionView를 받습니다.
  var setCollectionViewObserver: AnyObserver<UICollectionView> { get }
  
  /// 선택된 셀의 IndexPath를 전달합니다.
  var selectedArchiveCellObserver: AnyObserver<IndexPath> { get }
  
  /// 페이징을 처리하기 위한 Observer입니다. 
  var offsetObserver: AnyObserver<(viewHeight: CGFloat, offset: CGFloat)> { get }
  
  /// 업로드 버튼이 눌렸을 때를 인지하기 위한 Observer입니다.
  var uploadButtonObserver: AnyObserver<Void> { get }
  
  /// Bottom Sheet로부터 선택된 버튼 타입을 방출하는 Observer입니다.
  var bottomSheetTypeObserver: AnyObserver<ArchiveBottomSheetViewController.SelectedType> { get }
  
  // Output
  
  /// ArchivePopUpVC를 처리하는데 필요한 인자를 받습니다.
  var presentArchivePopUpObservable: Observable<(plubbingID: Int, archiveID: Int)> { get }
  
  /// ArchiveUploadVC를 띄우기 위해 필요한 인자를 받습니다.
  var presentArchiveUploadObservable: Observable<(plubbingID: Int, archiveID: Int)> { get }
  
  /// ArchiveBottomSheetVC를 띄웁니다.
  var presentBottomSheetObservable: Observable<(ArchiveContent.AccessType)> { get }
}

final class ArchiveViewModel {
  
  // MARK: - Properties
  
  private let plubbingID: Int
  private let getArchiveUseCase: GetArchiveUseCase
  private let deleteArchiveUseCase: DeleteArchiveUseCase
  
  private var dataSource: DataSource? {
    didSet {
      applyInitialSnapshots()
    }
  }
  
  private var archiveContents: [ArchiveContent] = [] {
    didSet {
      updateSnapshots()
    }
  }
  
  private let pagingManager = PagingManager<ArchiveContent>(threshold: 700)
  
  // MARK: Subjects
  
  private let setCollectionViewSubject      = PublishSubject<UICollectionView>()
  private let selectedArchiveCellSubject    = PublishSubject<IndexPath>()
  private let offsetSubject                 = PublishSubject<(viewHeight: CGFloat, offset: CGFloat)>()
  private let uploadButtonTappedSubject     = PublishSubject<Void>()
  private let recentTappedArchiveIDSubject  = PublishSubject<Int>()
  private let presentBottomSheetSubject     = PublishSubject<ArchiveContent.AccessType>()
  private let bottomSheetTypeSubject        = PublishSubject<ArchiveBottomSheetViewController.SelectedType>()
  
  // MARK: - Initialization
  
  init(
    plubbingID: Int,
    getArchiveUseCase: GetArchiveUseCase,
    deleteArchiveUseCase: DeleteArchiveUseCase
  ) {
    self.plubbingID = plubbingID
    self.getArchiveUseCase = getArchiveUseCase
    self.deleteArchiveUseCase = deleteArchiveUseCase
    
    fetchArchive(plubbingID: plubbingID)
    pagingSetup(plubbingID: plubbingID)
    removeArchive()
  }
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Configuration
  
  /// 초기 상태의 아카이브를 가져옵니다.
  private func fetchArchive(plubbingID: Int) {
    
    // PagingManager를 이용하여 아카이브 리스트를 가져옴
    let archivesObservable = pagingManager.fetchNextPage { [getArchiveUseCase] cursorID in
      getArchiveUseCase.execute(plubbingID: plubbingID, nextCursorID: cursorID)
    }
    
    Observable.combineLatest(setCollectionViewSubject, archivesObservable) {
      (collectionView: $0, archiveContents: $1)
    }
    .subscribe(with: self) { owner, tuple in
      owner.archiveContents = tuple.archiveContents
      owner.setCollectionView(tuple.collectionView)
    }
    .disposed(by: disposeBag)
  }
  
  /// 선택된 Cell의 IndexPath에 맞는 archiveID와 plubbingID를 emit합니다.
  private func findPlubbingIDAndArchiveID() -> Observable<(plubbingID: Int, archiveID: Int)> {
    selectedArchiveCellSubject
      .map(\.item)
      .compactMap { [weak self] index in self?.archiveContents[index].archiveID }
      .compactMap { [weak self] in
        guard let self else { return nil }
        return (plubbingID: self.plubbingID, archiveID: $0)
      }
  }
  
  /// 업로드 버튼, 또는 아카이브 수정 버튼이 눌렸을 때를 처리하기 위한 파이프라인 구성 코드 입니다.
  /// - Returns: ArchiveUploadViewModelFactory에 필요한 파라미터 인자인 `plubbingID`와 `archiveID`
  private func uploadOrEditButtonLogic() -> Observable<(plubbingID: Int, archiveID: Int)> {
    
    // 업로드 버튼 클릭된 경우
    let uploadPipeLine = uploadButtonTappedSubject.map { [plubbingID] _ in
      (plubbingID: plubbingID, archiveID: Int.min) // 업로드 버튼은 archiveID를 쓰지 않으므로 최솟값으로 설정
    }
    
    // 바텀시트로부터 아카이브 수정 버튼이 눌린 경우
    let editPipeLine = Observable.zip(bottomSheetTypeSubject.filter { $0 == .edit }, recentTappedArchiveIDSubject)
      .map { [plubbingID] in
        (plubbingID: plubbingID, archiveID: $1)
      }
    
    // 두 파이프라인을 합침
    return Observable.merge(uploadPipeLine, editPipeLine)
  }
  
  /// 아카이브 삭제 파이프라인 코드
  private func removeArchive() {
    bottomSheetTypeSubject
      .filter { $0 == .delete }
      .withLatestFrom(recentTappedArchiveIDSubject)
      .flatMap { [deleteArchiveUseCase] in
        deleteArchiveUseCase.execute(archiveID: $0)
      }
      .withLatestFrom(recentTappedArchiveIDSubject)
      .subscribe(with: self) { owner, archiveID in
        owner.archiveContents.removeAll {
          $0.archiveID == archiveID
        }
      }
      .disposed(by: disposeBag)
  }
  
  /// 페이징 처리를 진행합니다.
  private func pagingSetup(plubbingID: Int) {
    offsetSubject
      .filter { [pagingManager] in // pagingManager에게 fetching 가능한지 요청
        return pagingManager.shouldFetchNextPage(totalHeight: $0, offset: $1)
      }
      .flatMap { [weak self] _ -> Observable<[ArchiveContent]> in
        guard let self else { return .empty() }
        return self.pagingManager.fetchNextPage { cursorID in
          self.getArchiveUseCase.execute(plubbingID: plubbingID, nextCursorID: cursorID)
        }
      }
      .subscribe(with: self) { owner, content in
        owner.archiveContents.append(contentsOf: content)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - ArchiveViewModelType

extension ArchiveViewModel: ArchiveViewModelType {
  
  // MARK: Input
  
  var setCollectionViewObserver: AnyObserver<UICollectionView> {
    setCollectionViewSubject.asObserver()
  }
  
  var selectedArchiveCellObserver: AnyObserver<IndexPath> {
    selectedArchiveCellSubject.asObserver()
  }
  
  var offsetObserver: AnyObserver<(viewHeight: CGFloat, offset: CGFloat)> {
    offsetSubject.asObserver()
  }
  
  var uploadButtonObserver: AnyObserver<Void> {
    uploadButtonTappedSubject.asObserver()
  }
  
  var bottomSheetTypeObserver: AnyObserver<ArchiveBottomSheetViewController.SelectedType> {
    bottomSheetTypeSubject.asObserver()
  }
  
  // MARK: Output
  
  var presentArchivePopUpObservable: Observable<(plubbingID: Int, archiveID: Int)> {
    findPlubbingIDAndArchiveID()
  }
  
  var presentArchiveUploadObservable: Observable<(plubbingID: Int, archiveID: Int)> {
    uploadOrEditButtonLogic()
  }
  
  var presentBottomSheetObservable: Observable<(ArchiveContent.AccessType)> {
    presentBottomSheetSubject.asObservable()
  }
}

// MARK: - Diffable DataSources

extension ArchiveViewModel {
  typealias Section           = Int
  typealias Item              = ArchiveContent
  typealias DataSource        = UICollectionViewDiffableDataSource<Section, Item>
  typealias Snapshot          = NSDiffableDataSourceSnapshot<Section, Item>
  typealias CellRegistration  = UICollectionView.CellRegistration<ArchiveCollectionViewCell, ArchiveContent>
  
  // MARK: Snapshot & DataSource Part
  
  /// Collection View를 세팅하며, `DiffableDataSource`를 초기화하여 해당 Collection View에 데이터를 지닌 셀을 처리합니다.
  func setCollectionView(_ collectionView: UICollectionView) {
    
    // 단어 그대로 `등록`처리 코드, 셀 후처리할 때 사용됨
    let registration = CellRegistration { [weak self] cell, _, item in
      cell.delegate = self
      cell.configure(with: item)
    }
    
    // dataSource에 cell 등록
    dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
      return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
    }
  }
  
  /// 초기 Snapshot을 설정합니다. DataSource가 초기화될 시 해당 메서드가 실행됩니다.
  /// 직접 이 메서드를 실행할 필요는 없습니다.
  func applyInitialSnapshots() {
    var snapshot = Snapshot()
    snapshot.appendSections([0]) // 의무적으로 섹션 하나는 추가해야 함
    snapshot.appendItems(archiveContents)
    dataSource?.apply(snapshot)
  }
  
  func updateSnapshots() {
    guard var snapshot = dataSource?.snapshot() else { return }
    
    // 페이징 처리
    if let index = archiveContents.firstIndex(where: { !snapshot.itemIdentifiers.contains($0) }) {
      snapshot.appendItems(Array(archiveContents[index...]))
    }
    // 아카이브 삭제 처리
    if let itemToDelete = snapshot.itemIdentifiers.first(where: { !archiveContents.contains($0) }) {
      snapshot.deleteItems([itemToDelete])
    }

    dataSource?.apply(snapshot)
  }
}

// MARK: - ArchiveCollectionViewCellDelegate

extension ArchiveViewModel: ArchiveCollectionViewCellDelegate {
  func settingButtonTapped(archiveID: Int?) {
    guard let archiveID else {
      Log.error("아카이브 설정 버튼이 눌렸는데, archiveID값을 전달받지 못했습니다.")
      return
    }
    recentTappedArchiveIDSubject.onNext(archiveID)
    
    guard let accessType = archiveContents.first(where: { $0.archiveID == archiveID })?.accessType
    else {
      return
    }
    presentBottomSheetSubject.onNext(accessType)
  }
}
