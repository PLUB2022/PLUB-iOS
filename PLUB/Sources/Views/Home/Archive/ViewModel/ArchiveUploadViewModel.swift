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
  
  // MARK: Use Cases
  
  private let getArchiveDetailUseCase: GetArchiveDetailUseCase
  
  init(getArchiveDetailUseCase: GetArchiveDetailUseCase) {
    self.getArchiveDetailUseCase = getArchiveDetailUseCase
    
    setCollectionView()
  }
  
  private let disposeBag = DisposeBag()
}

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
  func setCollectionView() {
    
    let registration = UploadedCellRegistration { cell, _, imageLink in
      cell.configure(with: imageLink)
    }
    
    let headerRegistration = HeaderRegistration(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, _, _ in
    }
    
    setCollectionViewSubject
      .subscribe(with: self) { owner, collectionView in
        // dataSource에 cell 등록
        owner.dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
          return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
        
        // dataSource에 headerView도 등록
        owner.dataSource?.supplementaryViewProvider = .init { collectionView, _, indexPath in
          return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
      }
      .disposed(by: disposeBag)
  }
  
  /// 초기 Snapshot을 설정합니다. DataSource가 초기화될 시 해당 메서드가 실행됩니다.
  /// 직접 이 메서드를 실행할 필요는 없습니다.
  func applyInitialSnapshots() {
    var snapshot = Snapshot()
    snapshot.appendSections([.main])
    dataSource?.apply(snapshot)
  }
}
