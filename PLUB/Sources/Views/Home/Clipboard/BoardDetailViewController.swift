// 
//  BoardDetailViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/03/06.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class BoardDetailViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let viewModel: BoardDetailViewModelType & BoardDetailDataStore
  
  /// 게시글, 댓글에 대한 CollectionViewDiffableDataSource
  private var dataSource: DataSource?
  
  // MARK: - UI Components
  
  private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
    $0.register(BoardDetailCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BoardDetailCollectionHeaderView.identifier)
    $0.register(BoardDetailCollectionViewCell.self, forCellWithReuseIdentifier: BoardDetailCollectionViewCell.identifier)
    $0.backgroundColor = .background
  }
  
  // MARK: - Initializations
  
  init(viewModel: BoardDetailViewModelType & BoardDetailDataStore) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setCollectionView()
    applyInitialSnapshots()
    collectionView.delegate = self
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(collectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension BoardDetailViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return BoardDetailCollectionViewCell.estimatedCommentCellSize(CGSize(width: view.bounds.width, height: 0), comment: viewModel.comments[indexPath.item].content)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    // 첫 번째 section에만 게시글이 보이도록 설정
    guard section == 0 else { return .zero }
    // 동적 높이 처리
    let headerRegistration = HeaderRegistration(elementKind: UICollectionView.elementKindSectionHeader) { [viewModel] supplementaryView, elementKind, indexPath in
      supplementaryView.configure(with: viewModel.content.toBoardModel)
    }
    let indexPath = IndexPath(row: 0, section: section)
    let headerView = collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
    return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
  }
}

// MARK: - Diffable DataSource & Types

private extension BoardDetailViewController {
  
  // MARK: Type Alias
  
  typealias Section = Int
  typealias Item = CommentContent
  typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
  
  typealias CellRegistration = UICollectionView.CellRegistration<BoardDetailCollectionViewCell, CommentContent>
  typealias HeaderRegistration = UICollectionView.SupplementaryRegistration<BoardDetailCollectionHeaderView>
  
  // MARK: Snapshot & DataSource Part
  
  /// Collection View를 세팅하며, `DiffableDataSource`를 초기화하여 해당 Collection View에 데이터를 지닌 셀을 처리합니다.
  func setCollectionView() {
    
    // 단어 그대로 `등록`처리 코드, 셀 후처리할 때 사용됨
    let registration = CellRegistration { cell, _, item in
      cell.configure(with: item)
    }
    
    // Header View Registration, 헤더 뷰 후처리에 사용됨
    let headerRegistration = HeaderRegistration(elementKind: UICollectionView.elementKindSectionHeader) { [viewModel] supplementaryView, elementKind, indexPath in
      supplementaryView.configure(with: viewModel.content.toBoardModel)
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
    
    var sections = [-1] // 최소한 하나의 Section이라도 존재해야 함
    sections.append(contentsOf: Array(Set(viewModel.comments.map { $0.groupID })))
    snapshot.appendSections(sections)
    
    sections.forEach { sectionGroupID in
      snapshot.appendItems(viewModel.comments.filter { $0.groupID == sectionGroupID }, toSection: sectionGroupID)
    }
    dataSource?.apply(snapshot)
  }
}
