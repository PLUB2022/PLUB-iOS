//
//  NoSelectedCategoryView.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/03.
//

import UIKit

import SnapKit
import Then

class NoSelectedCategoryView: UIView {
  
  private lazy var stackView = UIStackView(arrangedSubviews: [
    grayView, alertLabel, createMeetingButton
  ]).then {
    $0.spacing = 32
    $0.axis = .vertical
    $0.alignment = .center
  }
  
  private let grayView = UIView().then {
    $0.backgroundColor = .noDataBackgroundColor
  }
  
  private let alertLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = .subtitle
    $0.textColor = .black
    $0.sizeToFit()
  }
  
  private let createMeetingButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "모임 만들러 가기")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    alertLabel.text = "아직 등록된 모집글이 없어요\n직접 모집글을 올려 볼까요?"
    addSubview(stackView)
    
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    grayView.snp.makeConstraints {
      $0.size.equalTo(140)
    }
    
    createMeetingButton.snp.makeConstraints {
      $0.left.right.equalToSuperview().inset(16)
      $0.height.equalTo(46)
    }
  }
}
