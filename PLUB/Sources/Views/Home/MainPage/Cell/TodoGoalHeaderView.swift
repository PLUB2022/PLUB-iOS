//
//  TodoGoalHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/24.
//

import UIKit

import SnapKit
import Then

final class TodoGoalHeaderView: UICollectionReusableView {
  
  static let identifier = "TodoGoalHeaderView"
  
  private let titleLabel = UILabel().then {
    $0.font = .appFont(family: .nanum, size: 32)
    $0.textAlignment = .center
    $0.numberOfLines = 0
  }
  
  private let goalBackgroundView = UIView().then {
    $0.backgroundColor = .subMain
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [goalBackgroundView, titleLabel].forEach { addSubview($0) }
    
    goalBackgroundView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(40)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(187)
      $0.height.equalTo(19)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(24)
      $0.directionalHorizontalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    titleLabel.text = model
  }
}
