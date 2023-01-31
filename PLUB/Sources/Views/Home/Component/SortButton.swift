//
//  SortButton.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/31.
//

import UIKit

import SnapKit
import Then

enum SortType {
  case popular
  case new
  
  var text: String {
    switch self {
    case .new:
      return "최신순"
    case .popular:
      return "인기순"
    }
  }
}

class SortButton: UIView {
  
  private let type: SortType
  
  private let sortLabel = UILabel().then {
    $0.text = "인기순"
    $0.font = .caption
    $0.textColor = .main
    $0.sizeToFit()
  }
  
  private let sortImageView = UIImageView().then {
    $0.image = UIImage(named: "sort")
    $0.contentMode = .scaleAspectFill
  }
  
  init(type: SortType) {
    self.type = type
    super.init(frame: .zero)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [sortLabel, sortImageView].forEach { addSubview($0) }
    
    sortLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalToSuperview().inset(10)
    }
    
    sortImageView.snp.makeConstraints { make in
      make.top.bottom.right.equalToSuperview()
      make.left.equalTo(sortLabel.snp.right)
    }
    
    sortLabel.text = type.text
  }
}
