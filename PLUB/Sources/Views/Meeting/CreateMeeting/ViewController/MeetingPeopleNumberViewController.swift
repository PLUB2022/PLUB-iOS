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
  
  private let peopleNumberToolTip = PeopleNumberToolTip()
  
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
    
    [contentStackView, peopleNumberToolTip].forEach {
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
    
    peopleNumberToolTip.snp.makeConstraints {
      $0.width.equalTo(58)
      $0.height.equalTo(31)
      $0.bottom.equalTo(slider.snp.top).offset(-2)
      $0.leading.equalToSuperview().inset(8.5)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
    
    let sliderValue = slider.rx.value
      .map{ Int($0) }
    
    sliderValue
      .bind(to: viewModel.peopleNumber)
      .disposed(by: disposeBag)
    
    sliderValue
      .withUnretained(self)
      .asDriver(onErrorDriveWith: .empty())
      .skip(1)
      .drive(onNext: { owner, value in
        owner.peopleNumberToolTip.setupCountLabelText(peopleCount: value)
        owner.peopleNumberToolTip.center = owner.getSliderThumbCenter(slider: owner.slider)
      })
      .disposed(by: disposeBag)
  }
  
  private func getSliderThumbCenter(slider: UISlider) -> CGPoint {
    let sliderTrack: CGRect = slider.trackRect(forBounds: slider.bounds) // slider 트랙 좌표
    let sliderThumb: CGRect = slider.thumbRect(forBounds: slider.bounds, trackRect: sliderTrack, value: slider.value) // slider 원 좌표
    
    let centerX = slider.frame.origin.x + sliderThumb.origin.x + sliderThumb.size.width / 2 + 24 // slider x좌표 + slider 원 x좌표 + slider 너비 / 2 + contentStackView의 leading inset 값
    let centerY = slider.frame.origin.y - 15.5 - 2 // slider y좌표 - peopleNumberToolTip 높이 / 2 - peopleNumberToolTip과 slider간 padding 값
    
    return CGPoint(x: centerX, y: centerY)
  }
}
