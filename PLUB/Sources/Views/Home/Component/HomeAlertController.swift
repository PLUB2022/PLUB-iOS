//
//  HomeAlert.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/06.
//

import UIKit

import Lottie
import RxSwift
import SnapKit
import Then

protocol HomeAlertDelegate: AnyObject {
  func dismissHomeAlert()
}

final class HomeAlertController: BaseViewController {
  
  weak var delegate: HomeAlertDelegate?
  
  private let backgroundView = UIView().then {
    $0.backgroundColor = .black.withAlphaComponent(Constants.backgroundAlphaTo)
  }
  
  private let alertView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 12
    $0.isUserInteractionEnabled = true
    $0.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
  }
  
  private lazy var stackView = UIStackView(arrangedSubviews: [applyImageView, mainLabel, subLabel, descriptionLabel]).then {
    $0.axis = .vertical
    $0.distribution = .fill
    $0.alignment = .center
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: 28, bottom: 32, right: 28)
  }
  
  private let applyImageView = LottieAnimationView().then {
    $0.contentMode = .scaleAspectFill
    $0.animation = .named("SuccessApply")
  }
  
  private lazy var backButton = UIButton().then {
    $0.setImage(UIImage(named: "closeButton"), for: .normal)
  }
  
  private let mainLabel = UILabel().then {
    $0.textColor = .main
    $0.font = .h4
    $0.text = "지원완료 !"
    $0.numberOfLines = 0
    $0.sizeToFit()
  }
  
  private let subLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .body2
    $0.numberOfLines = 0
    $0.sizeToFit()
    $0.text = """
    정성스럽게 작성하신 답변을
    모임 호스트에게 전달했어요.
    """
  }
  
  private let descriptionLabel = UILabel().then {
    $0.text = """
    호스트가 수락하면 함께 활동할 수 있습니다.
    알림으로 알려드릴게요!
    """
    $0.textColor = .deepGray
    $0.numberOfLines = 0
    $0.font = .caption
  }
  
  private let tapGesture = UITapGestureRecognizer(target: HomeAlertController.self, action: nil)
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // curveEaseOut: 시작은 천천히, 끝날 땐 빠르게
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut) { [weak self] in
      self?.alertView.transform = .identity
      self?.alertView.isHidden = false
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // curveEaseIn: 시작은 빠르게, 끝날 땐 천천히
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn) { [weak self] in
      self?.alertView.transform = .identity
      self?.alertView.isHidden = true
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    backgroundView.addGestureRecognizer(tapGesture)
    applyImageView.play()
  }
  
  override func bind() {
    super.bind()
    
    tapGesture.rx.event
      .subscribe(with: self) { owner, _ in
        owner.dismiss(animated: false)
        owner.delegate?.dismissHomeAlert()
      }
      .disposed(by: disposeBag)
    
    backButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.dismiss(animated: false)
        owner.delegate?.dismissHomeAlert()
      }
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [backgroundView, alertView].forEach { view.addSubview($0) }
    [backButton, stackView].forEach { alertView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    backgroundView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    alertView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.equalTo(296)
      $0.height.equalTo(448)
    }
    
    backButton.snp.makeConstraints {
      $0.width.height.equalTo(32)
      $0.top.trailing.equalToSuperview().inset(10)
    }
    
    stackView.snp.makeConstraints {
      $0.top.equalTo(backButton.snp.bottom).offset(0.5)
      $0.leading.trailing.bottom.equalToSuperview()
    }
    
    stackView.setCustomSpacing(8, after: mainLabel)
    stackView.setCustomSpacing(32, after: subLabel)
  }
}

extension HomeAlertController {
  enum Constants {
    static let backgroundAlphaTo = 0.6
  }
}
