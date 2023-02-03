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
  
  static let identifier = "RecentSearchListCollectionViewCell"
  
  private let recentSearchLabel = UILabel().then {
    $0.numberOfLines = 1
    $0.lineBreakMode = .byTruncatingTail
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 14)
    $0.sizeToFit()
  }
  
  private let removeButton = UIButton().then {
    $0.setImage(UIImage(named: "xMark"), for: .normal)
    $0.contentMode = .scaleAspectFit
  }
  
  private let borderView = UIView().then {
    $0.backgroundColor = .lightGray
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [recentSearchLabel, removeButton, borderView].forEach { contentView.addSubview($0) }
    
    removeButton.snp.makeConstraints {
      $0.top.right.bottom.equalToSuperview()
      $0.size.equalTo(32)
    }
    
    recentSearchLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.left.equalToSuperview().inset(8)
      $0.top.bottom.equalToSuperview().inset(7)
      $0.right.lessThanOrEqualTo(removeButton.snp.left)
    }
    
    borderView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.left.right.bottom.equalToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    recentSearchLabel.text = model
  }
}
