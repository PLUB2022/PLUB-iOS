//
//  LocationControl.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/20.
//

import UIKit

import RxCocoa
import RxSwift

final class LocationControl: UIControl {

  var date = Date() {
    didSet {
      label.text = DateFormatter().then {
        $0.dateFormat = "a hh시 mm분"
        $0.locale = Locale(identifier: "ko_KR")
      }.string(from: date)
    }
  }

  override var isSelected: Bool {
    didSet {
      if isSelected {
        imageView.image = UIImage(named: "locationActivated")
        setupStyles()
      }
    }
  }

  private let label = UILabel().then {
    $0.text = "장소를 검색해주세요"
    $0.font = .subtitle
  }

  private let imageView = UIImageView().then {
    $0.image = UIImage(named: "locationInactivated")
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
    imageView.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(8)
      $0.centerY.equalToSuperview()
      $0.size.equalTo(18)
    }
    
    label.snp.makeConstraints {
      $0.leading.equalTo(imageView.snp.trailing).offset(8)
      $0.centerY.equalTo(imageView.snp.centerY)
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

extension Reactive where Base: LocationControl {

  /// Reactive wrapper for `TouchUpInside` control event.
  var tap: ControlEvent<Void> {
    controlEvent(.touchUpInside)
  }
}
