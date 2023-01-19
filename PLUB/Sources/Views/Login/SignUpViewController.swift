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
  
  // MARK: - Properties
  
  private let viewModel = SignUpViewModel()
  
  private var currentPage = 0 {
    didSet {
      view.endEditing(true)
      pageControl.currentPage = currentPage
      titleLabel.text = viewModel.titles[currentPage]
      subtitleLabel.text = viewModel.subtitles[currentPage]
    }
  }
  
  private var lastPageIndex = 0 {
    didSet {
      view.endEditing(true)
      contentStackView.addArrangedSubview(viewControllers[lastPageIndex].view)
      viewControllers[lastPageIndex].view.snp.makeConstraints {
        $0.width.equalTo(view.snp.width)
      }
    }
  }
  
  private var viewControllers = [
    PolicyViewController(),
    BirthViewController(),
    ProfileViewController(),
    IntroductionViewController()
  ]
  
  // MARK: UI Properties
  
  private let stackView = UIStackView().then {
    $0.alignment = .leading
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private lazy var pageControl = PageControl().then {
    $0.numberOfPages = viewControllers.count
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
  
  private lazy var scrollView = UIScrollView().then {
    $0.bounces = false
    $0.isPagingEnabled = true
    $0.showsHorizontalScrollIndicator = false
    $0.delegate = self
  }
  
  private let contentStackView = UIStackView().then {
    $0.backgroundColor = .background
  }
  
  private var nextButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "다음")
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    
    viewControllers.forEach { addChild($0) }
    
    [stackView, scrollView, nextButton].forEach {
      view.addSubview($0)
    }
    
    scrollView.addSubview(contentStackView)
    
    
    contentStackView.addArrangedSubview(viewControllers.first!.view)
    
    [pageControl, titleLabel, subtitleLabel].forEach {
      stackView.addArrangedSubview($0)
    }
    viewControllers.forEach { $0.didMove(toParent: self) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    stackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(28)
      $0.horizontalEdges.equalToSuperview().inset(24)
    }
    
    scrollView.snp.makeConstraints {
      $0.top.equalTo(stackView.snp.bottom).offset(48)
      $0.horizontalEdges.bottom.equalToSuperview()
    }
    
    contentStackView.snp.makeConstraints {
      $0.edges.equalTo(scrollView.contentLayoutGuide)
      $0.height.equalTo(scrollView.snp.height)
      $0.width.greaterThanOrEqualToSuperview().priority(.low)
    }
    
    viewControllers.first!.view.snp.makeConstraints {
      $0.width.equalTo(view.snp.width)
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
