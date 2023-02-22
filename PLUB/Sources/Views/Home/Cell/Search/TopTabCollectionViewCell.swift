//
//  ToptabCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/05.
//

import UIKit

import SnapKit
import Then

enum FilterType: CaseIterable { // 모집글 검색을 위한 필터타입
  case title // 제목
  case name // 모임이름
  case mix // 제목 + 글
  
  var toEng: String {
    switch self {
    case .title:
      return "title"
    case .name:
      return "name"
    case .mix:
      return "mix"
    }
  }
  
  var toKor: String {
    switch self {
    case .title:
      return "제목"
    case .name:
      return "모임이름"
    case .mix:
      return "제목+글"
    }
  }
}

class TopTabCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "TopTabCollectionViewCell"
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .body1
    $0.textAlignment = .center
    $0.sizeToFit()
  }
  
  override var isSelected: Bool {
    willSet {
      if newValue {
        titleLabel.textColor = .main
      } else {
        titleLabel.textColor = .black
      }
    }
  }
  
  override func prepareForReuse() {
    isSelected = false
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    titleLabel.text = model
  }
}
