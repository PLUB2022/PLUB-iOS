//
//  FilterCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/12.
//

import UIKit

import SnapKit
import Then

struct RecruitmentFilterCollectionViewCellModel {
  let subCategoryID: Int
  let name: String
}

class RecruitmentFilterCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "RecruitmentFilterCollectionViewCell"
  
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
  
  private func configureUI() {
    contentView.layer.borderWidth = 1
    contentView.layer.borderColor = UIColor.deepGray.cgColor
    contentView.layer.cornerRadius = 8
    contentView.layer.masksToBounds = true
    contentView.backgroundColor = .white
    
    contentView.addSubview(interestTypeLabel)
    interestTypeLabel.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  public func configureUI(with model: String) {
    interestTypeLabel.text = model
  }
  
  public func configureUI(with model: RecruitmentFilterCollectionViewCellModel) {
    interestTypeLabel.text = model.name
  }
}
