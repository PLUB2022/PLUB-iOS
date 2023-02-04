//
//  MeetingCreateSuccessViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/03.
//

import UIKit

final class MeetingCreateSuccessViewController: BaseViewController {
  
  private let successImageView = UIImageView().then {
    $0.image = UIImage() //TODO: 수빈 - 모임 생성 완료 이미지 추가하기
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
    [successImageView, successTitleLabel, buttonStackView].forEach {
      view.addSubview($0)
    }
    
    [myPostButton, mainPageButton].forEach {
      buttonStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    successImageView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(50)
      $0.height.equalTo(Device.width - 50 * 2)
      $0.center.equalToSuperview()
    }
    
    successTitleLabel.snp.makeConstraints {
      $0.top.equalTo(successImageView.snp.bottom).offset(16)
      $0.centerX.equalToSuperview()
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
  }
  
  override func bind() {
    super.bind()
  }
}
