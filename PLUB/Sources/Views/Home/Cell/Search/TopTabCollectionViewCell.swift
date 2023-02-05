//
//  ToptabCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/05.
//

import UIKit

import SnapKit
import Then

class TopTabCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "TopTabCollectionViewCell"
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .body1
    $0.sizeToFit()
  }
  
  override var isSelected: Bool {
    willSet {
      if newValue {
        titleLabel.textColor = .main
      } else {
        titleLabel.textColor = .black
      }
    }
  }
  
  override func prepareForReuse() {
    isSelected = false
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.center.left.right.equalToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    titleLabel.text = model
  }
}
