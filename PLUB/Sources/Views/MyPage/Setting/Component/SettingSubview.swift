//
//  SettingSubview.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/19.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

final class SettingSubview: UIView {
  private let label = UILabel().then {
    $0.font = .appFont(family: .pretendard(option: .bold), size: 18)
    $0.textColor = .black
  }
  
  private lazy var versionLabel = UILabel().then {
    $0.font = .appFont(family: .pretendard(option: .regular), size: 14)
    $0.textColor = .mediumGray
    if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      $0.text = appVersion
    }
  }

  init(_ title: String, isSubLabel: Bool = false) {
    label.text = title
    super.init(frame: .zero)
    setupLayouts(isSubLabel: isSubLabel)
    setupConstraints(isSubLabel: isSubLabel)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupLayouts(isSubLabel: Bool) {
    addSubview(label)
    if isSubLabel {
      addSubview(versionLabel)
    }
  }

  private func setupConstraints(isSubLabel: Bool) {
    label.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(12)
      $0.centerY.equalToSuperview()
      $0.height.equalTo(21)
      $0.top.equalToSuperview().inset(19)
      $0.bottom.equalToSuperview().inset(10)
    }
    
    if isSubLabel {
      versionLabel.snp.makeConstraints {
        $0.centerY.equalTo(label.snp.centerY)
        $0.leading.equalTo(label.snp.trailing).offset(12)
      }
    }
  }
}
