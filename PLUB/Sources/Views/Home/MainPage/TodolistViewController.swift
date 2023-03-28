//
//  TodolistViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/02.
//

import UIKit

import SnapKit
import Then

final class TodolistViewController: BaseViewController {
  
  private let titleLabel = UILabel().then {
    $0.font = .appFont(family: .nanum, size: 32)
    $0.text = "“2주에 한 권씩”"
    $0.addLineSpacing($0)
  }
  
  private let todoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
    $0.backgroundColor = .background
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .background
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [titleLabel, todoCollectionView].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(16)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(40)
    }
    
    todoCollectionView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
  }
}
