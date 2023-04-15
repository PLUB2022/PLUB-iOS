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
  
  // Output
}

final class ArchiveViewModel {
  
  // MARK: - Properties
  
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

  // MARK: - Initialization
  
  init(plubbingID: Int) {
    
  }
  
  private let disposeBag = DisposeBag()
}

// MARK: - ArchiveViewModelType

extension ArchiveViewModel: ArchiveViewModelType {
  
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
