//
//  CalendarControl.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/19.
//

import UIKit

final class CalendarControl: UIControl {
  
  var title = "날짜를 선택해주세요."
  
  override var isSelected: Bool {
    didSet {
      if isSelected {
        imageView.image = UIImage(named: "scheduleActivated")
        setupStyles()
      }
    }
  }
  
  private lazy var label = UILabel().then {
    $0.text = title
    $0.font = .subtitle
  }
  
  private let imageView = UIImageView().then {
    $0.image = UIImage(named: "scheduleInactivated")
    $0.contentMode = .scaleAspectFit
  }
  
  init() {
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    addSubview(label)
    addSubview(imageView)
  }
  
  private func setupConstraints() {
    label.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(16)
      $0.centerY.equalToSuperview()
    }
    imageView.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(12)
      $0.centerY.equalToSuperview()
      $0.size.equalTo(32)
    }
  }
  
  private func setupStyles() {
    layer.borderWidth = 1
    layer.cornerRadius = 8
    if isSelected {
      label.textColor = .black
      layer.borderColor = UIColor.main.cgColor
    } else {
      label.textColor = .deepGray
      layer.borderColor = UIColor.deepGray.cgColor
    }
  }
}
