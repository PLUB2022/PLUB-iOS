//
//  CreateMeetingTitleView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/15.
//

import UIKit

import SnapKit

final class CreateMeetingTitleView: UIView {
  
  private let stackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 4
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "이 모임을 뭐라고 부를까요?"
    $0.font = .h4
    $0.textColor = .black
  }
  
  private let descriptionLabel = UILabel().then {
    $0.text = "소개 타이틀, 모임 이름을 적어주세요."
    $0.font = .subtitle
    $0.textColor = .deepGray
  }
  
  init(
    title: String,
    description: String
  ) {
    super.init(frame: .zero)
    
    titleLabel.text = title
    descriptionLabel.text = description
    setupLayouts()
    setupConstraints()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    addSubview(stackView)
    [titleLabel, descriptionLabel].forEach {
      stackView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    stackView.snp.makeConstraints{
      $0.top.bottom.equalToSuperview()
      $0.leading.trailing.equalToSuperview()
    }
  }
}
