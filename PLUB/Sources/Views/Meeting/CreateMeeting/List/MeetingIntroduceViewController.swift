//
//  MeetingIntroduceViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/15.
//

import UIKit

import RxSwift
import SnapKit

final class MeetingIntroduceViewController: BaseViewController {
  
  // MARK: - Property
  
  private let scrollView = UIScrollView().then {
    $0.bounces = false
    $0.contentInsetAdjustmentBehavior = .never
    $0.showsVerticalScrollIndicator = false
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 48
  }
  
  private let titleView = CreateMeetingTitleView(
    title: "우리 모임은 어떤 모임인가요?",
    description: "모임에 대해서 자세하게 설명해주세요."
  )
    
  private let goalView = InputTextView(
    title: "모임 목표",
    placeHolder: "소개하는 내용을 입력해주세요",
    options: [.textCount]
  )
  
  private let introduceView = InputTextView(
    title: "모임 소개글",
    placeHolder: "우리동네 사진모임"
  )

  private let photoStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }

  private let photoTitleLabel = UILabel().then {
    $0.font = .subtitle
    $0.textColor = .black
    $0.text = "모임 소개 사진 (선택)"
  }

  private let photoSelectView = PhotoSelectView()
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(contentStackView)
    
    [titleView, goalView, introduceView, photoStackView].forEach {
      contentStackView.addArrangedSubview($0)
    }
    
    [photoTitleLabel, photoSelectView].forEach {
      photoStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    scrollView.snp.makeConstraints {
        $0.top.equalTo(view.safeAreaLayoutGuide)
        $0.leading.trailing.bottom.equalToSuperview()
    }
    
    contentStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalTo(scrollView.snp.width)
    }
    
    contentStackView.setCustomSpacing(56, after: introduceView)
    
    photoTitleLabel.snp.makeConstraints {
      $0.height.equalTo(19)
      $0.leading.trailing.equalToSuperview().inset(24)
    }

    photoSelectView.snp.makeConstraints {
      $0.height.equalTo(100)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
  }
}
