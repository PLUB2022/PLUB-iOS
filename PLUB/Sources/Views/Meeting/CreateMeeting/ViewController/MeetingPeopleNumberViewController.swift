//
//  MeetingPeopleNumberViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/09.
//

import UIKit

import RxSwift
import RxCocoa

final class MeetingPeopleNumberViewController: BaseViewController {
  
  private var viewModel: MeetingPeopleNumberViewModel
  weak var delegate: CreateMeetingChildViewControllerDelegate?
  private var childIndex: Int
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 48
  }
  
  private let titleView = CreateMeetingTitleView(
    title: "몇명이서 만날까요?",
    description: "함께 하고자 하는 적정 인원 수를 적어주세요."
  )
  
  private let subtitleLabel = UILabel().then {
    $0.text = "몇 명인가요?"
    $0.font = .subtitle
    $0.textColor = .black
  }
  
  private let slider = UISlider().then {
    $0.value = 0
    $0.tintColor = .main
    $0.minimumValue = 4
    $0.maximumValue = 20
  }
  
  private let countStactView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 0
    $0.distribution = .equalSpacing
  }
  
  private let minCountLabel = UILabel().then {
    $0.text = "4명"
    $0.font = .caption
    $0.textColor = .black
    $0.textAlignment = .left
  }
  
  private let maxCountLabel = UILabel().then {
    $0.text = "20명"
    $0.font = .caption
    $0.textColor = .black
    $0.textAlignment = .right
  }
  
  init(
    viewModel: MeetingPeopleNumberViewModel,
    childIndex: Int
  ) {
    self.viewModel = viewModel
    self.childIndex = childIndex
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    delegate?.checkValidation(
      index: childIndex,
      state: true
    )
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [contentStackView].forEach {
      view.addSubview($0)
    }
    
    [titleView, subtitleLabel, slider, countStactView].forEach {
      contentStackView.addArrangedSubview($0)
    }
    
    [minCountLabel, maxCountLabel].forEach {
      countStactView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    contentStackView.snp.makeConstraints {
        $0.top.equalTo(view.safeAreaLayoutGuide)
        $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    subtitleLabel.snp.makeConstraints {
      $0.height.equalTo(19)
    }
    
    slider.snp.makeConstraints {
      $0.height.equalTo(30)
    }
    
    contentStackView.setCustomSpacing(40, after: subtitleLabel)
    
    contentStackView.setCustomSpacing(3, after: slider)
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
    
    slider.rx.value
      .map{ Int($0) }
      .bind(to: viewModel.peopleNumber)
      .disposed(by: disposeBag)
  }
}
