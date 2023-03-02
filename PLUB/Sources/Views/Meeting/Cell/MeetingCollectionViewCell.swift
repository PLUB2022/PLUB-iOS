//
//  MeetingCollectionViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/02.
//

import UIKit

final class MeetingCollectionViewCell: UICollectionViewCell {
  static let identifier = "MeetingCollectionViewCell"
  
  private var label = UILabel().then {
    $0.font = .h3
    $0.textColor = .deepGray
    $0.textAlignment = .center
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
    
  private func setupLayouts() {
    addSubview(label)
  }
    
  private func setupConstraints() {
    label.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  private func setupStyles() {
    backgroundColor = .clear
    
    layer.cornerRadius = 8
    layer.borderWidth = 1
    layer.borderColor = UIColor.deepGray.cgColor
  }
  
  func setupData(with data: MyPlubbing) {
    label.text = data.name
  }
  
  func setupCreateCell() {
    label.text = "+"
  }
}
