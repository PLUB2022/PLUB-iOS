//
//  SignUpViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/19.
//

import UIKit

import SnapKit
import Then

final class SignUpViewController: BaseViewController {
  // MARK: UI Properties
  
  private let stackView = UIStackView().then {
    $0.alignment = .leading
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private lazy var pageControl = PageControl().then {
    $0.numberOfPages = 4
  }
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.font = .h4
  }
  
  private let subtitleLabel = UILabel().then {
    $0.font = .body2
    $0.textColor = .black
    $0.numberOfLines = 0
  }
  
  private var nextButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "다음")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [stackView, nextButton].forEach {
      view.addSubview($0)
    }
    
    [pageControl, titleLabel, subtitleLabel].forEach {
      stackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    stackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(28)
      $0.horizontalEdges.equalToSuperview().inset(24)
    }
    
    nextButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(4)
      $0.horizontalEdges.equalToSuperview().inset(24)
      $0.height.equalTo(48)
    }
    
    stackView.setCustomSpacing(24, after: pageControl)
  }
  
  
  override func setupStyles() {
    super.setupStyles()
  }
}
