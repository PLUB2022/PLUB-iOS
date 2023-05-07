//
//  TodoInfoView.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/31.
//

import UIKit

import SnapKit
import Then

final class TodoInfoView: UIView {
  
  private let checkImageView = UIImageView().then {
    $0.image = UIImage(named: "Check")
    $0.backgroundColor = .main
    $0.contentMode = .scaleAspectFit
  }
  
  private let todoLabel = UILabel().then {
    $0.textColor = .deepGray
    $0.font = .systemFont(ofSize: 14)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [checkImageView, todoLabel].forEach { addSubview($0) }
    checkImageView.snp.makeConstraints {
      $0.centerY.leading.equalToSuperview()
      $0.size.equalTo(12)
    }
    
    todoLabel.snp.makeConstraints {
      $0.leading.equalTo(checkImageView.snp.trailing).offset(8)
      $0.centerY.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    todoLabel.attributedText = model.strikeThrough()
  }
}
