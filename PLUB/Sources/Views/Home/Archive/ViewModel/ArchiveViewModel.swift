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
  
  // Output
  
  /// ArchivePopUpVC를 처리하는데 필요한 인자를 받습니다.
  var presentArchivePopUpObservable: Observable<(plubbingID: Int, archiveID: Int)> { get }
  
  /// ArchiveUploadVC를 띄우기 위해 필요한 인자를 받습니다.
  var presentArchiveUploadObservable: Observable<(plubbingID: Int, archiveID: Int)> { get }
}

final class ArchiveViewModel {
  
  // MARK: - Properties
  
  private let plubbingID: Int
  private let getArchiveUseCase: GetArchiveUseCase
  
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
  
  private let setCollectionViewSubject    = PublishSubject<UICollectionView>()
  private let selectedArchiveCellSubject  = PublishSubject<IndexPath>()
  private let offsetSubject               = PublishSubject<(viewHeight: CGFloat, offset: CGFloat)>()
  private let uploadButtonTappedSubject   = PublishSubject<Void>()
  
  // MARK: - Initialization
  
  init(plubbingID: Int, getArchiveUseCase: GetArchiveUseCase) {
    self.plubbingID = plubbingID
    self.getArchiveUseCase = getArchiveUseCase
    
    fetchArchive(plubbingID: plubbingID)
    pagingSetup(plubbingID: plubbingID)
  }
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Configuration
  
  /// 초기 상태의 아카이브를 가져옵니다.
  private func fetchArchive(plubbingID: Int) {
    
    // PagingManager를 이용하여 아카이브 리스트를 가져옴
    let archivesObservable = pagingManager.fetchNextPage { [getArchiveUseCase] cursorID in
      getArchiveUseCase.execute(plubbingID: plubbingID, nextCursorID: cursorID)
    }
    
    setCollectionViewSubject
      .take(1)
      .withLatestFrom(archivesObservable) { (collectionView: $0, archiveContents: $1) }
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
  
  // MARK: Output
  
  var presentArchivePopUpObservable: Observable<(plubbingID: Int, archiveID: Int)> {
    findPlubbingIDAndArchiveID()
  }
  
  var presentArchiveUploadObservable: Observable<(plubbingID: Int, archiveID: Int)> {
    // TODO: 승현 - 아카이브 수정 시 보내야하는 plubbingID와 archiveID도 같이 merge해야함
    uploadButtonTappedSubject.compactMap { [plubbingID] _ in
      (plubbingID, 0) // 업로드 버튼은 archiveID를 쓰지 않으므로 임의의 값 0을 주입
    }
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
    let registration = CellRegistration { cell, _, item in
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
    
    guard let index = archiveContents.firstIndex(where: { !snapshot.itemIdentifiers.contains($0) })
    else {
      return
    }
    
    snapshot.appendItems(Array(archiveContents[index...]))
    
    dataSource?.apply(snapshot)
  }
}
