//
//  MainPageViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/01.
//

import UIKit

import SnapKit
import Then
/// 메인페이지 탑 탭바 타입
enum MainPageFilterType {
  case board
  case todoList
  
  var title: String {
    switch self {
    case .board:
      return "게시글"
    case .todoList:
      return "그룹원 TO-DO 리스트"
    }
  }
}

final class MainPageViewController: BaseViewController {
  
  private let segmentedControl = UnderlineSegmentedControl(
    items: [MainPageFilterType.board.title, MainPageFilterType.todoList.title]
  ).then {
    $0.setTitleTextAttributes([.foregroundColor: UIColor.mediumGray, .font: UIFont.body1!], for: .normal)
    $0.setTitleTextAttributes([.foregroundColor: UIColor.main, .font: UIFont.body1!], for: .selected)
    $0.selectedSegmentIndex = 0
  }
  
  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sec, env -> NSCollectionLayoutSection? in
    guard let self = self else { return nil }
      return type(of: self).createLayoutSection(viewType: .normal)
  }).then {
    $0.backgroundColor = .background
  }
  
  private let writeButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "+ 새 글 작성")
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [segmentedControl, writeButton].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    segmentedControl.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(16)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(32)
    }
    
    writeButton.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(24)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(110)
      $0.height.equalTo(32)
    }
  }
  
  private static func createLayoutSection(viewType: ViewType) -> NSCollectionLayoutSection {
    switch viewType {
    case .normal:
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .fractionalHeight(1)
        )
      )
      
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(85)),
        subitem: item,
        count: 4
      )
      
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(120)
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .none
      section.boundarySupplementaryItems = [header]
      section.contentInsets = .init(top: .zero, leading: .zero, bottom: 37, trailing: .zero)
      return section
    case .pin:
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .fractionalHeight(1)
        )
      )
      
      let verticalItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .absolute(85)))
      
      let verticalGroup = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(85)
        ),
        subitem: verticalItem,
        count: 2
      )
      
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(85)
        ), subitems: [
          item,
          verticalGroup
        ]
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .none
      return section
      
    case .system:
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .fractionalHeight(1)
        )
      )
      
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(85)),
        subitem: item,
        count: 4
      )
      
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(120)
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .none
      section.boundarySupplementaryItems = [header]
      section.contentInsets = .init(top: .zero, leading: .zero, bottom: 37, trailing: .zero)
      return section
    }
  }
}
