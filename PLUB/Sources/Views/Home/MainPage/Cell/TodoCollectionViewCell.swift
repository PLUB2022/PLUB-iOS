//
//  TodoCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/28.
//

import UIKit

import SnapKit
import Then

final class TodoCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "TodoCollectionViewCell"
  
  private let profileImageView = UIImageView().then {
    $0.image = UIImage(systemName: "person.fill")
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 12
  }
  
  private let heartImageView = UIImageView().then {
    $0.image = UIImage(named: "heartFilled")
  }
  
  private let heartCountLabel = UILabel().then {
    $0.textColor = .mediumGray
    $0.font = .caption2
    $0.text = "0"
  }
  
  private let listContainerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [profileImageView, heartImageView, heartCountLabel, listContainerView].forEach { contentView.addSubview($0) }
    
    profileImageView.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
      $0.size.equalTo(24)
    }
    
    heartImageView.snp.makeConstraints {
      $0.top.equalTo(profileImageView.snp.bottom).offset(10.67)
      $0.trailing.equalTo(profileImageView.snp.centerX).offset(-1)
      $0.size.equalTo(16)
    }
    
    heartCountLabel.snp.makeConstraints {
      $0.top.equalTo(heartImageView)
      $0.leading.equalTo(heartImageView.snp.trailing).offset(1)
    }
    
    listContainerView.snp.makeConstraints {
      $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
      $0.directionalVerticalEdges.trailing.equalToSuperview()
    }
  }
}
