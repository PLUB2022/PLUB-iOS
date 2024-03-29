
//
//  InterestTypeCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/11/24.
//

import UIKit

import SnapKit
import Then

final class InterestTypeCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "InterestTypeCollectionViewCell"
  
  var isTapped: Bool = false {
    didSet {
      contentView.backgroundColor = isTapped ? .main : .white
      interestTypeLabel.textColor = isTapped ? .white : .deepGray
      contentView.layer.borderColor = isTapped ? UIColor.main.cgColor : UIColor.deepGray.cgColor
    }
  }
  
  private let interestTypeLabel = UILabel().then {
    $0.textColor = .deepGray
    $0.font = .caption
    $0.textAlignment = .center
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    interestTypeLabel.text = nil
    isTapped = false
  }
  
  private func configureUI() {
    contentView.layer.borderWidth = 1
    contentView.layer.borderColor = UIColor.deepGray.cgColor
    contentView.layer.cornerRadius = 8
    contentView.layer.masksToBounds = true
    contentView.backgroundColor = .white
    
    contentView.addSubview(interestTypeLabel)
    interestTypeLabel.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: SubCategoryStatus) {
    interestTypeLabel.text = model.name
    isTapped = model.isSelected
  }
}
