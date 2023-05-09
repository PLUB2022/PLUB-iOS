//
//  MeetingCreateSuccessViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/03.
//

import UIKit

import Lottie

final class MeetingCreateSuccessViewController: BaseViewController {
  
  private let animationView = LottieAnimationView().then {
    $0.contentMode = .scaleAspectFill
    $0.animation = .named("CreateMeeting")
  }
  
  private let successTitleLabel = UILabel().then {
    $0.text = "모임 생성 완료!"
    $0.font = .h3
    $0.textColor = .black
    $0.textAlignment = .center
  }
  
  private let buttonStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private var myPostButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "내가 쓴 글 보기")
    $0.isEnabled = false
  }
  
  private var mainPageButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "메인으로")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [animationView, successTitleLabel, buttonStackView].forEach {
      view.addSubview($0)
    }
    
    [myPostButton, mainPageButton].forEach {
      buttonStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    animationView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(Device.width)
      $0.centerX.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(26)
    }
    
    successTitleLabel.snp.makeConstraints {
      $0.bottom.equalTo(animationView.snp.bottom)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(29)
    }
    
    buttonStackView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.bottom.equalToSuperview().inset(26)
    }
    
    [myPostButton, mainPageButton].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(46)
      }
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    navigationItem.setHidesBackButton(true, animated: true)
    animationView.play()
  }
  
  override func bind() {
    super.bind()
    myPostButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        //TODO: 수빈 - 내가 쓴 글 보기 화면 이동 추가
      }
      .disposed(by: disposeBag)
    
    mainPageButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.navigationController?.popToRootViewController(animated: true)
      }
      .disposed(by: disposeBag)
  }
}
