//
//  PeopleNumberToolTip.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/05.
//

import UIKit

final class PeopleNumberToolTip: UIView {
  private let currentCountLabel = UILabel().then {
    $0.text = "4명"
    $0.textAlignment = .center
    $0.textColor = .white
    $0.font = .subtitle
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 10
    $0.backgroundColor = .main
  }
  
  private let polygonImageView = UIImageView().then {
    $0.image = UIImage(named: "polygonPurple")
  }
  
  init() {
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    [currentCountLabel, polygonImageView].forEach {
      addSubview($0)
    }
  }
  
  private func setupConstraints() {
    currentCountLabel.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.width.equalTo(58)
      $0.height.equalTo(27)
    }
    
    polygonImageView.snp.makeConstraints {
      $0.top.equalTo(currentCountLabel.snp.bottom).offset(-2)
      $0.centerX.equalToSuperview()
      $0.size.equalTo(6)
      $0.bottom.equalToSuperview()
    }
  }
  
  func setupCountLabelText(peopleCount: Int) {
    currentCountLabel.text = "\(peopleCount)명"
  }
}
