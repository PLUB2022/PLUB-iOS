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
  
  // Output
  
  /// ArchivePopUpVC를 처리하는데 필요한 인자를 받습니다.
  var presentArchivePopUpObservable: Observable<(plubbingID: Int, archiveID: Int)> { get }
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
      
    }
  }
  
  private let pagingManager = PagingManager<ArchiveContent>(threshold: 700)
  
  private let setCollectionViewSubject    = PublishSubject<UICollectionView>()
  private let selectedArchiveCellSubject  = PublishSubject<IndexPath>()
  
  // MARK: - Initialization
  
  init(plubbingID: Int, getArchiveUseCase: GetArchiveUseCase) {
    self.plubbingID = plubbingID
    self.getArchiveUseCase = getArchiveUseCase
    
    fetchArchive(plubbingID: plubbingID)
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
  
  private func findPlubbingIDAndArchiveID() -> Observable<(plubbingID: Int, archiveID: Int)> {
    selectedArchiveCellSubject
      .map(\.item)
      .compactMap { [weak self] index in self?.archiveContents[index].archiveID }
      .compactMap { [weak self] in
        guard let self else { return nil }
        return (plubbingID: plubbingID, archiveID: $0)
      }
  }
}

// MARK: - ArchiveViewModelType

extension ArchiveViewModel: ArchiveViewModelType {
  var setCollectionViewObserver: AnyObserver<UICollectionView> {
    setCollectionViewSubject.asObserver()
  }
  
  var selectedArchiveCellObserver: AnyObserver<IndexPath> {
    selectedArchiveCellSubject.asObserver()
  }
  
  var presentArchivePopUpObservable: Observable<(plubbingID: Int, archiveID: Int)> {
    findPlubbingIDAndArchiveID()
  }
}

// MARK: - Diffable DataSources

extension ArchiveViewModel {
  typealias Section = Int
  typealias Item    = ArchiveContent
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
  
  typealias CellRegistration = UICollectionView.CellRegistration<ArchiveCollectionViewCell, ArchiveContent>
  
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
}
