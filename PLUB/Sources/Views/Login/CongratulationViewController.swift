//
//  CongratulationViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/02.
//

import UIKit

import Lottie

final class CongratulationViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let animationView = LottieAnimationView().then {
    $0.contentMode = .scaleAspectFill
    $0.animation = .named("Congratuation")
  }
  
  private let congratuationLabel = UILabel().then {
    $0.font = .appFont(family: .nanum, size: 32)
    $0.text = "\"환영합니다!\""
    $0.textAlignment = .center
    $0.numberOfLines = 0
  }
  
  private let nextButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "PLUB 시작!")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [animationView, congratuationLabel, nextButton].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    animationView.snp.makeConstraints {
      $0.centerY.equalToSuperview().dividedBy(1.46)
      $0.centerX.equalToSuperview()
      $0.size.equalTo(260)
    }
    
    congratuationLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.centerX.equalToSuperview()
    }
    
    nextButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Metric.nextButtonBottom)
      $0.directionalHorizontalEdges.equalToSuperview().inset(24)
      $0.height.equalTo(48)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    animationView.play()
  }
}

extension CongratulationViewController {
  private enum Metric {
    static let nextButtonBottom = Device.isNotch ? 4 : 24
  }
}
