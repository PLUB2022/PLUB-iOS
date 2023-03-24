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

enum HomeAlertType {
  case successApply
  case cancelApply
}

protocol HomeAlertDelegate: AnyObject {
  func didTappedBackButton()
  func didTappedYesButton()
  func didTappedNoButton()
}

final class HomeAlert: BaseViewController {
  
  private let type: HomeAlertType
  weak var delegate: HomeAlertDelegate?
  
  private let alertView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 12
    $0.isUserInteractionEnabled = true
    $0.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
  }
  
  /// successApply일 경우 사용되는 UI
  private lazy var stackView = UIStackView(arrangedSubviews: [applyImageView, mainLabel, subLabel, descriptionLabel]).then {
    $0.axis = .vertical
    $0.distribution = .fill
    $0.alignment = .center
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: 28, bottom: 32, right: 28)
  }
  
  private lazy var applyImageView = UIImageView().then {
    $0.image = UIImage(named: "apply")
    $0.contentMode = .scaleAspectFill
  }
  
  private lazy var backButton = UIButton().then {
    $0.setImage(UIImage(named: "closeButton"), for: .normal)
  }
  
  private lazy var mainLabel = UILabel().then {
    $0.textColor = .main
    $0.font = .h4
    $0.text = "지원완료 !"
    $0.numberOfLines = 0
    $0.sizeToFit()
  }
  
  private lazy var subLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .body2
    $0.numberOfLines = 0
    $0.sizeToFit()
    $0.text = """
    정성스럽게 작성하신 답변을
    모임 호스트에게 전달했어요.
    """
  }
  
  private lazy var descriptionLabel = UILabel().then {
    $0.text = """
    호스트가 수락하면 함께 활동할 수 있습니다.
    알림으로 알려드릴게요!
    """
    $0.textColor = .deepGray
    $0.numberOfLines = 0
    $0.font = .caption
  }
  
  /// cancelApply일 경우 사용되는 UI
  private lazy var buttonStackView = UIStackView(arrangedSubviews: [noButton, yesButton]).then {
    $0.axis = .horizontal
    $0.spacing = 12
  }
  
  private lazy var noButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "아니오")
    $0.backgroundColor = .lightGray
    $0.tintColor = .deepGray
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.cornerRadius = 8
  }
  
  private lazy var yesButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "네")
    $0.isSelected = true
  }
  
  private let tapGesture = UITapGestureRecognizer(target: HomeAlert.self, action: nil)
  
  init(type: HomeAlertType) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
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
    view.backgroundColor = .black.withAlphaComponent(Constants.backgroundAlphaTo)
    view.addGestureRecognizer(tapGesture)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [alertView].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    switch type {
    case .successApply:
      alertView.snp.makeConstraints {
        $0.center.equalToSuperview()
        $0.width.equalTo(296)
        $0.height.equalTo(448)
      }
    case .cancelApply:
      alertView.snp.makeConstraints {
        $0.center.equalToSuperview()
        $0.width.equalTo(296)
        $0.height.equalTo(210)
      }
    }
    
  }
  
  override func bind() {
    super.bind()
    backButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedBackButton()
      }
      .disposed(by: disposeBag)
    
    tapGesture.rx.event
      .subscribe(with: self) { owner, _ in
        owner.dismiss(animated: false)
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
  
  private func configureUI() {
    switch type {
    case .successApply:
      [backButton, stackView].forEach { alertView.addSubview($0) }
      
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
  
}

extension HomeAlert {
  struct Constants {
    static let backgroundAlphaTo = 0.6
  }
}

extension HomeAlert: HomeAlertDelegate {
  func didTappedBackButton() {}
  func didTappedYesButton() {}
  func didTappedNoButton() {}
}

