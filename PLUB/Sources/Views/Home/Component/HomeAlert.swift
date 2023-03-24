//
//  HomeAlert.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/06.
//

import UIKit

import RxSwift
import SnapKit
import Then

protocol HomeAlertDelegate: AnyObject {
  func didTappedCancelButton()
  func didTappedYesButton()
  func didTappedNoButton()
}

extension HomeAlertDelegate {
  func didTappedCancelButton() {}
  func didTappedYesButton() {}
  func didTappedNoButton() {}
}

enum HomeAlertType {
  case applyCompleted
  case cancelApply
}

final class HomeAlert {
  
  weak var delegate: HomeAlertDelegate?
  private let disposeBag = DisposeBag()
  static let shared = HomeAlert()
  
  private let backgroundView = UIView().then {
    $0.backgroundColor = .black
    $0.alpha = 0
  }
  
  private let alertView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 12
    $0.isUserInteractionEnabled = true
  }
  
  private lazy var stackView = UIStackView(arrangedSubviews: [applyImageView, mainLabel, subLabel, descriptionLabel]).then {
    $0.axis = .vertical
    $0.distribution = .fill
    $0.alignment = .center
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: 28, bottom: 32, right: 28)
  }
  
  private let applyImageView = UIImageView().then {
    $0.image = UIImage(named: "apply")
    $0.contentMode = .scaleAspectFill
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
  
  private lazy var buttonStackView = UIStackView(arrangedSubviews: [noButton, yesButton]).then {
    $0.axis = .horizontal
    $0.spacing = 12
  }
  
  private let noButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "아니오")
    $0.backgroundColor = .lightGray
    $0.tintColor = .deepGray
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.cornerRadius = 8
  }
  
  private let yesButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "네")
    $0.isSelected = true
  }
  
  private let tapGesture = UITapGestureRecognizer(target: HomeAlert.self, action: nil)
  
  private init() {
    backgroundView.addGestureRecognizer(tapGesture)
    bind()
  }
  
  private func bind() {
    tapGesture.rx.event
      .subscribe(with: self) { owner, _ in
        owner.dismissAlert()
      }
      .disposed(by: disposeBag)
    
    backButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.dismissAlert()
      }
      .disposed(by: disposeBag)
    
    yesButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedYesButton()
      }
      .disposed(by: disposeBag)
    
    noButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedNoButton()
      }
      .disposed(by: disposeBag)
  }
  
  public func showAlert(type: HomeAlertType = .applyCompleted) {
    guard let keyWindow = UIApplication.shared.connectedScenes
      .filter({$0.activationState == .foregroundActive})
      .compactMap({$0 as? UIWindowScene})
      .first?.windows
      .filter({$0.isKeyWindow}).first else { return }
    
    alertView.removeFromSuperview()
    [backgroundView, alertView].forEach { keyWindow.addSubview($0) }
    backgroundView.alpha = Constants.backgroundAlphaTo
    backgroundView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    switch type {
    case .applyCompleted:
      [backButton, stackView].forEach { alertView.addSubview($0) }
      
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
    case .cancelApply:
      [mainLabel, buttonStackView].forEach { alertView.addSubview($0) }
      alertView.snp.makeConstraints {
        $0.center.equalToSuperview()
        $0.width.equalTo(296)
        $0.height.equalTo(210)
      }
    
      mainLabel.text = "이 모임에 참여하고 싶지\n 않으신가요?"
      mainLabel.snp.makeConstraints {
        $0.top.equalToSuperview().inset(59)
        $0.directionalHorizontalEdges.equalToSuperview().inset(48)
      }
      
      buttonStackView.snp.makeConstraints {
        $0.directionalHorizontalEdges.bottom.equalToSuperview().inset(16)
        $0.height.equalTo(46)
      }
      
    }
    
  }
  
  private func dismissAlert() {
    UIView.animate(withDuration: 0.25) {
      self.backgroundView.alpha = 0
    } completion: { done in
      if done {
        self.alertView.removeFromSuperview()
        self.backgroundView.removeFromSuperview()
        self.delegate?.didTappedCancelButton()
      }
    }
  }
}

extension HomeAlert {
  struct Constants {
    static let backgroundAlphaTo = 0.6
  }
}
