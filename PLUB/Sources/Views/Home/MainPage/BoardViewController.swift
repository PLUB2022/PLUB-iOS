//
//  BoardViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/02.
//

import UIKit

import SnapKit
import Then

final class BoardViewController: BaseViewController {
  
  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()).then {
      $0.backgroundColor = .background
      $0.register(BoardCollectionViewCell.self, forCellWithReuseIdentifier: BoardCollectionViewCell.identifier)
      $0.delegate = self
      $0.dataSource = self
    }
  
  override func setupStyles() {
    super.setupStyles()
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

extension BoardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardCollectionViewCell.identifier, for: indexPath) as? BoardCollectionViewCell ?? BoardCollectionViewCell()
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
  }
}
}
