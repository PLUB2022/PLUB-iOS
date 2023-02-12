//
//  RecruitmentFilterViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/12.
//

import UIKit

import SnapKit
import Then

final class RecruitmentFilterViewController: BaseViewController {
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 24)
  }
  
  private let filterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
    $0.backgroundColor = .background
  }
  
  override func setupStyles() {
    super.setupStyles()
    self.navigationItem.leftBarButtonItem = uibarbu
    
  }
}
