//
//  RecentSearchListCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/03.
//

import UIKit

import SnapKit
import Then

class RecentSearchListCollectionViewCell: UICollectionViewCell {
  
  private let recentSearchLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 14)
    $0.sizeToFit()
  }
  
  private let removeButton = UIButton().then {
    $0.setImage(UIImage(named: ""), for: .normal)
    $0.contentMode = .scaleAspectFit
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [recentSearchLabel, removeButton].forEach { contentView.addSubview($0) }
    recentSearchLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.left.equalToSuperview().inset(8)
      $0.top.bottom.equalToSuperview().inset(7)
    }
    
    removeButton.snp.makeConstraints {
      $0.top.right.bottom.equalToSuperview()
      $0.size.equalTo(32)
    }
  }
}
