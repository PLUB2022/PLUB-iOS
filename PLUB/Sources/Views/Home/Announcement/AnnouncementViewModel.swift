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
  
  var requestFetchingAnnouncement: AnyObserver<Void> { get }
  
  // Output
}

final class AnnouncementViewModel {
  
  private var dataSource: DataSource?
  
  private let pagingManager = PagingManager<AnnouncementContent>(threshold: 700)
  
  private var contentModels: Set<AnnouncementContent> = []
  
  // MARK: - Use Cases
  
  private let getAnnouncementUseCase: GetAnnouncementUseCase
  
  // MARK: - Subjects
  
  private let collectionViewSubject     = PublishSubject<UICollectionView>()
  private let fetchAnnouncementSubject  = PublishSubject<Void>()
  
  // MARK: - Initialization
  
  init(getAnnouncementUseCase: GetAnnouncementUseCase) {
    self.getAnnouncementUseCase = getAnnouncementUseCase
    fetchAnnouncement()
    setCollectionDataSource()
  }
  
  private let disposeBag = DisposeBag()
}


private extension AnnouncementViewModel {
  
  /// 공지 API를 호출하여 값을 가져옵니다.
  func fetchAnnouncement() {
    fetchAnnouncementSubject
      .flatMap { [getAnnouncementUseCase] _ in getAnnouncementUseCase.execute(nextCursorID: 0) }
      .subscribe(with: self) { owner, tuple in
        owner.contentModels.formUnion(tuple.content)
        owner.addNewItemsToSnapshots()
      }
      .disposed(by: disposeBag)
  }
  
  func setCollectionDataSource() {
    collectionViewSubject
      .subscribe(with: self) { owner, collectionView in
        
        let registration = CellRegistration { cell, indexPath, itemIdentifier in
          guard let model = owner.contentModels.first(where: { $0.noticeID == itemIdentifier }) else { return }
          cell.configure(with: model)
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
  
  var requestFetchingAnnouncement: AnyObserver<Void> {
    fetchAnnouncementSubject.asObserver()
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
  typealias CellRegistration = UICollectionView.CellRegistration<AnnouncementCollectionViewCell, Item>
  
  
  func addNewItemsToSnapshots() {
    guard let dataSource else { return }
    var snapshot = dataSource.snapshot(for: .main)
    
    let newItems = Set(contentModels.map(\.noticeID)).subtracting(Set(snapshot.items))
    
    // 값이 존재하면 새로운 아이템을 맨 앞에 insert
    if let firstItem = snapshot.items.first {
      snapshot.insert(Array(newItems), before: firstItem)
    } else {
      // snapshot에 값이 없으면 단순 append
      snapshot.append(Array(newItems))
    }
    
    dataSource.apply(snapshot, to: .main)
  }
}
