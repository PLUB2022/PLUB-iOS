//
//  FilterCollectionHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/12.
//

import UIKit

import SnapKit
import Then

class RecruitmentFilterCollectionHeaderView: UICollectionReusableView {
  
  static let identifier = "RecruitmentFilterCollectionHeaderView"
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .subtitle
    $0.sizeToFit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
    }
  }
  
  public func configureUI(with model: String) {
    titleLabel.text = model
  }
}
