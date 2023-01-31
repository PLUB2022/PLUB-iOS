//
//  SortButton.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/31.
//

import UIKit

import RxSwift
import RxCocoa
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

final class SortControl: UIControl {
  
  private let type: SortType
  
  var sortChanged: SortType = .popular {
    didSet {
      sortLabel.text = sortChanged.text
    }
  }
  
  private let sortLabel = UILabel().then {
    $0.text = "인기순"
    $0.font = .caption
    $0.textColor = .main
    $0.sizeToFit()
  }
  
  private let sortImageView = UIImageView().then {
    $0.image = UIImage(named: "filledTriangleDown")
    $0.contentMode = .scaleAspectFill
  }
  
  init(type: SortType = .popular) {
    self.type = type
    super.init(frame: .zero)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [sortLabel, sortImageView].forEach { addSubview($0) }
    
    sortLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.left.equalToSuperview().inset(10)
    }
    
    sortImageView.snp.makeConstraints {
      $0.top.bottom.right.equalToSuperview()
      $0.left.equalTo(sortLabel.snp.right)
    }
    
    sortLabel.text = type.text
    layer.masksToBounds = true
    layer.cornerRadius = 12
    layer.borderWidth = 1
    layer.borderColor = UIColor.main.cgColor
  }
}

extension Reactive where Base: SortControl {
  var tap: ControlEvent<Void> {
    controlEvent(.touchUpInside)
  }
}
