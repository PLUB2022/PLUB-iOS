//
//  MeetingNameViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/08.
//

import UIKit

import RxSwift
import SnapKit

final class MeetingNameViewController: BaseViewController {
  
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
    title: "이 모임을 뭐라고 부를까요?",
    description: "소개 타이틀, 모임 이름을 적어주세요."
  )
    
  private let introduceTitleView = InputTextView(
    title: "소개 타이틀",
    placeHolder: "소개하는 내용을 입력해주세요",
    options: [.textCount, .questionMark]
  )
  
  private let nameTitleView = InputTextView(
    title: "모임 이름",
    placeHolder: "우리동네 사진모임",
    options: [.textCount, .questionMark],
    totalCharacterLimit: 60
  )
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(contentStackView)
    
    [titleView, introduceTitleView, nameTitleView].forEach {
      contentStackView.addArrangedSubview($0)
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
    
    contentStackView.setCustomSpacing(43, after: introduceTitleView)
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
  }
}
