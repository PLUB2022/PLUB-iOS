//
//  IntroduceTagCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/17.
//

import UIKit

import SnapKit
import Then

final class IntroduceTagCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "IntroduceTagCollectionViewCell"
  
  private let tagLabel = UILabel().then {
    $0.font = .caption
    $0.textColor = .main
    $0.textAlignment = .center
    $0.sizeToFit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configreUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configreUI() {
    contentView.backgroundColor = .subMain
    contentView.layer.masksToBounds = true
    contentView.layer.cornerRadius = 4
    
    contentView.addSubview(tagLabel)
    
    tagLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    tagLabel.text = model
  }
}
