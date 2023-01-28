//
//  QuestionHeaderView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/28.
//

import UIKit

import SnapKit
import RxSwift

protocol QuestionHeaderViewCellDelegate: AnyObject {
  func chageQuestionMode(state: Bool)
}

final class QuestionHeaderView: UIView {
  private let disposeBag = DisposeBag()
  
  weak var delegate: QuestionHeaderViewCellDelegate?
  
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
    $0.isSelected = true
  }
  
  private let noquestionButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "질문 없이 모집하기")
  }
  
  
  init() {
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
    setupStyles()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private extension QuestionHeaderView {
  func setupLayouts() {
    [contentStackView].forEach {
      addSubview($0)
    }
    
    [titleView, questionStackView].forEach {
      contentStackView.addArrangedSubview($0)
    }
    
    [questionButton, noquestionButton].forEach {
      questionStackView.addArrangedSubview($0)
    }
  }
  
  func setupConstraints() {
    contentStackView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    [questionButton, noquestionButton].forEach{
      $0.snp.makeConstraints {
        $0.height.equalTo(46)
      }
    }
  }
  
  func setupStyles() {

  }
  
  func bind() {
    questionButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.questionButton.isSelected = true
        owner.noquestionButton.isSelected = false
        owner.delegate?.chageQuestionMode(state: false)
      })
      .disposed(by: disposeBag)
    
    noquestionButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.questionButton.isSelected = false
        owner.noquestionButton.isSelected = true
        owner.delegate?.chageQuestionMode(state: true)
      })
      .disposed(by: disposeBag)
  }
}
