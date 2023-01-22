//
//  MeetingQuestionViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/09.
//

import UIKit

final class MeetingQuestionViewController: BaseViewController {
  weak var delegate: CreateMeetingChildViewControllerDelegate?
  private var childIndex: Int
  
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
    title: "어떤 게스트가 오면 좋을까요?",
    description: "함께 할 게스트에게 질문하고 싶은 내용을 적어주세요!\n꼭 적지 않아도 괜찮아요."
  )
  
  private let questionStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 16
    $0.distribution = .fillEqually
  }
  
  private let questionButton: UIButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "질문 하고 모집하기")
  }
  
  private let noquestionButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "질문 없이 모집하기")
  }
  
  init(
    childIndex: Int
  ) {
    self.childIndex = childIndex
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(contentStackView)
    
    [titleView, questionStackView].forEach {
      contentStackView.addArrangedSubview($0)
    }
    
    [questionButton, noquestionButton].forEach {
      questionStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    scrollView.snp.makeConstraints {
        $0.top.equalTo(view.safeAreaLayoutGuide)
        $0.leading.trailing.bottom.equalToSuperview().inset(24)
    }
    
    contentStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalTo(scrollView.snp.width)
    }
    
    
    [questionButton, noquestionButton].forEach{
      $0.snp.makeConstraints {
        $0.height.equalTo(46)
      }
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
  }
}
