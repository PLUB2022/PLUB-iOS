//
//  TodoCollectionHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/03.
//

import UIKit

import SnapKit
import Then

struct TodoCollectionHeaderViewModel {
  let isToday: Bool
  let date: String
}

final class TodoCollectionHeaderView: UICollectionReusableView {
  
  static let identifier = "TodoCollectionHeaderView"
  
  private let dateLabel = UILabel().then {
    $0.font = .body1
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
    addSubview(dateLabel)
    dateLabel.snp.makeConstraints {
      $0.centerY.leading.equalToSuperview()
    }
  }
  
  func configureUI(with model: TodoCollectionHeaderViewModel) {
    dateLabel.textColor = model.isToday ? .black : .mediumGray
    dateLabel.text = model.isToday ? "\(model.date)(오늘)" : model.date
  }
}
