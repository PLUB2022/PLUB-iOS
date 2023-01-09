//
//  HomeMainHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/10.
//

import UIKit
import SnapKit
import Then

class HomeMainCollectionHeaderView: UICollectionReusableView {
  
  static let identifier = "HomeMainCollectionHeaderView"
  
  private let headerTitleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .h3
    $0.text = "좋아하는 분야에서\n모임을 시작하세요!"
    $0.numberOfLines = 0
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
    backgroundColor = .background
    addSubview(headerTitleLabel)
    headerTitleLabel.snp.makeConstraints {
      $0.left.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-24)
    }
  }
}
