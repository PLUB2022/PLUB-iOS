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
}

final class HomeAlert: BaseViewController {
  
  private let type: HomeAlertType
  weak var delegate: HomeAlertDelegate?
  
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
  
  init(type: HomeAlertType) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .clear
    backgroundView.alpha = Constants.backgroundAlphaTo
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(backgroundView)
    view.addSubview(alertView)
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
  }
  
  override func bind() {
    super.bind()
    backButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedBackButton()
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
}
