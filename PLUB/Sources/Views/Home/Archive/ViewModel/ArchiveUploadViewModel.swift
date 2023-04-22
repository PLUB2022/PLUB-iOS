// 
//  ArchiveUploadViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/17.
//

import UIKit

import RxSwift
import RxCocoa

protocol ArchiveUploadViewModelType {
  // Input
  var collectionViewObserver: AnyObserver<UICollectionView> { get }
  
  // Output
}

final class ArchiveUploadViewModel {
  
  // MARK: - Properties
  
  private var dataSource: DataSource? {
    didSet {
      applyInitialSnapshots()
    }
  }
  
  private var archivesContents = [String]()
  
  // MARK: Subjects
  
  private let setCollectionViewSubject = PublishSubject<UICollectionView>()
  private let archiveTitleSubject      = BehaviorSubject<String>(value: "")
  
  // MARK: Use Cases
  
  private let getArchiveDetailUseCase: GetArchiveDetailUseCase
  
  init(getArchiveDetailUseCase: GetArchiveDetailUseCase) {
    self.getArchiveDetailUseCase = getArchiveDetailUseCase
    
    fetchArchives()
  }
  
  private let disposeBag = DisposeBag()
}

// MARK: - Binding Methods

private extension ArchiveUploadViewModel {
  
  /// 아카이브를 조회한 결과 값을 토대로 View를 업데이트합니다.
  func fetchArchives() {
    
    Observable.combineLatest(getArchiveDetailUseCase.execute(), setCollectionViewSubject) {
      (content: $0, collectionView: $1)
    }
    .subscribe(with: self) { owner, tuple in
      owner.archivesContents = tuple.content.images
      owner.setCollectionView(tuple.collectionView, titleText: tuple.content.title)
      owner.archiveTitleSubject.onNext(tuple.content.title)
    }
    .disposed(by: disposeBag)
  }
}

// MARK: - ArchiveUploadViewModelType

extension ArchiveUploadViewModel: ArchiveUploadViewModelType {
  var collectionViewObserver: AnyObserver<UICollectionView> {
    setCollectionViewSubject.asObserver()
  }
}

// MARK: - Diffable DataSource

private extension ArchiveUploadViewModel {
  
  // MARK: Type Alias
  
  enum Section {
    case main
  }
  
  typealias Item = String
  typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
  
  typealias UploadedCellRegistration = UICollectionView.CellRegistration<ArchiveUploadedPictureCell, Item>
  typealias UploadCellRegistration = UICollectionView.CellRegistration<ArchiveUploadCell, Item>
  typealias HeaderRegistration = UICollectionView.SupplementaryRegistration<ArchiveUploadHeaderView>
  
  // MARK: Snapshot & DataSource Part
  
  /// Collection View를 세팅하며, `DiffableDataSource`를 초기화하여 해당 Collection View에 데이터를 지닌 셀을 처리합니다.
  func setCollectionView(_ collectionView: UICollectionView, titleText: String) {
    
    let registration = UploadedCellRegistration { cell, _, imageLink in
      cell.configure(with: imageLink)
    }
    
    let headerRegistration = HeaderRegistration(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, _, _ in
      guard let self else { return }
      supplementaryView.configure(with: titleText)
      supplementaryView.delegate = self
    }
    
    // dataSource에 cell 등록
    dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
      return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
    }
    
    // dataSource에 headerView도 등록
    dataSource?.supplementaryViewProvider = .init { collectionView, _, indexPath in
      return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
    }
  }
  
  /// 초기 Snapshot을 설정합니다. DataSource가 초기화될 시 해당 메서드가 실행됩니다.
  /// 직접 이 메서드를 실행할 필요는 없습니다.
  func applyInitialSnapshots() {
    var snapshot = Snapshot()
    snapshot.appendSections([.main])
    snapshot.appendItems(archivesContents)
    dataSource?.apply(snapshot)
  }
}

// MARK: - ArchiveUploadHeaderViewDelegate

extension ArchiveUploadViewModel: ArchiveUploadHeaderViewDelegate {
  func archiveTitle(text: String) {
    archiveTitleSubject.onNext(text)
  }
}
