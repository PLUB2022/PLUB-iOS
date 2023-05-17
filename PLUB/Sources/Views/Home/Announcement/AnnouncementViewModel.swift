// 
//  AnnouncementViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/05/16.
//

import UIKit

import RxSwift
import RxCocoa

protocol AnnouncementViewModelType {
  // Input
  
  var setCollectionViewObserver: AnyObserver<UICollectionView> { get }
  
  // Output
}

final class AnnouncementViewModel {
  
  private var dataSource: DataSource?
  
  // MARK: - Subjects
  
  private let collectionViewSubject = PublishSubject<UICollectionView>()
  
  // MARK: - Initialization
  
  init() {
    setCollectionDataSource()
  }
  
  private let disposeBag = DisposeBag()
}


private extension AnnouncementViewModel {
  func setCollectionDataSource() {
    collectionViewSubject
      .subscribe(with: self) { owner, collectionView in
        
        let registration = CellRegistration { cell, indexPath, itemIdentifier in
          var config = cell.defaultContentConfiguration()
          config.text = "Hello, World \(itemIdentifier)"
          cell.contentConfiguration = config
        }
        
        owner.dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
          collectionView.dequeueConfiguredReusableCell(
            using: registration,
            for: indexPath,
            item: itemIdentifier
          )
        }
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - AnnouncementViewModelType

extension AnnouncementViewModel: AnnouncementViewModelType {
  
  // MARK: Input
  
  var setCollectionViewObserver: AnyObserver<UICollectionView> {
    collectionViewSubject.asObserver()
  }
  
  // MARK: Output
  
}

// MARK: - Diffable DataSource & Snapshot

extension AnnouncementViewModel {
  
  enum Section {
    case main
  }
  
  typealias Item = Int
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
  typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>
  typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item>
}
