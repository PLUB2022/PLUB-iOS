//
//  WeekDateCollectionViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/19.
//

import UIKit

final class WeekDateCollectionViewCell: UICollectionViewCell {
  static let identifier = "WeekDateCollectionViewCell"
  
  private var label = UILabel().then {
    $0.font = .caption
    $0.textColor = .deepGray
    $0.textAlignment = .center
  }
  
  override var isSelected: Bool {
    didSet {
      guard isSelected != oldValue else { return }
      setupSelected(isSelected)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}

private extension WeekDateCollectionViewCell {
  func setupLayouts() {
    addSubview(label)
  }
    
  func setupConstraints() {
    label.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  func setupStyles() {
    backgroundColor = .clear
    
    layer.cornerRadius = 8
    layer.borderWidth = 1
    layer.borderColor = UIColor.deepGray.cgColor
  }
    
  func setupSelected(_ selected: Bool) {
    backgroundColor = selected ? .main : .clear
    layer.borderColor = selected ? UIColor.clear.cgColor : UIColor.deepGray.cgColor
    label.textColor = selected ? .white : .deepGray
    label.font = selected ? .caption2 : .caption
  }
}

extension WeekDateCollectionViewCell {
  func setupData(dateText: String) {
    label.text = dateText
  }
}
