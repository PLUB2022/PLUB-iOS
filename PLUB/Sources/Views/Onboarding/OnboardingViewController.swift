//
//  OnboardingViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/31.
//

import UIKit

import RxCocoa
import RxSwift
import Lottie
import SnapKit
import Then

final class OnboardingViewController: BaseViewController {
  
  private let viewModel = OnboardingViewModel()
  
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
  
  override func setupStyles() {
    super.setupStyles()
    
    let skipButton = UIButton().then {
      $0.setTitle("SKIP", for: .normal)
      $0.setTitleColor(.main, for: .normal)
      $0.titleLabel?.font = .button
      $0.addTarget(self, action: #selector(moveToLoginViewController), for: .touchUpInside)
    }
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: skipButton)
  }
  
  override func bind() {
    super.bind()
    
    nextButton.rx.tap
      .bind(to: viewModel.nextButtonTapped)
      .disposed(by: disposeBag)
    
    viewModel.emitTitles
      .drive(titleLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.emitDescriptions
      .drive(descriptionLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.emitCurrentPage
      .drive(pageControl.rx.currentPage)
      .disposed(by: disposeBag)
    
    viewModel.shouldMoveLoginVC
      .filter { $0 }
      .drive(with: self) { owner, _ in
        owner.moveToLoginViewController()
      }
      .disposed(by: disposeBag)
  }
  
  @objc
  private func moveToLoginViewController() {
    navigationController?.setViewControllers([LoginViewController()], animated: true)
  }
}

// MARK: - Constants

extension OnboardingViewController {
  private enum Metric {
    static let nextButtonBottom = Device.isNotch ? 4 : 24
  }
}
