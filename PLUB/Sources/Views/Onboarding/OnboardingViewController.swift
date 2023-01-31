//
//  OnboardingViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/31.
//

import UIKit

import Lottie
import SnapKit
import Then

final class OnboardingViewController: BaseViewController {
  
  private let onboardingView = LottieAnimationView().then {
    $0.backgroundColor = .red
  }
  
  private let titleLabel = UILabel().then {
    $0.textAlignment = .center
    $0.text = "취향을 함께"
    $0.font = .onboarding
  }
  
  private let descriptionLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.textAlignment = .center
    $0.text = "좋아하는 것들을\n함께 나눌 사람들을 찾아보아요"
    $0.font = .body2
  }
  
  private let pageControl = PageControl().then {
    $0.numberOfPages = 3
    $0.currentPageIndicatorWidth = 24
  }
  
  private let nextButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "다음")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [onboardingView, titleLabel, descriptionLabel, pageControl, nextButton].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    onboardingView.snp.makeConstraints {
      $0.size.equalTo(240)
      $0.centerX.equalToSuperview()
      $0.centerY.equalToSuperview().dividedBy(1.564)
    }
    
    titleLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.centerY.equalToSuperview().multipliedBy(1.32)
    }
    
    descriptionLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom).offset(16)
    }
    
    nextButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Metric.nextButtonBottom)
      $0.directionalHorizontalEdges.equalToSuperview().inset(24)
      $0.height.equalTo(48)
    }
    
    pageControl.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(nextButton.snp.top).offset(-24)
    }
  }
}

// MARK: - Constants

extension OnboardingViewController {
  private enum Metric {
    static let nextButtonBottom = Device.isNotch ? 4 : 24
  }
}