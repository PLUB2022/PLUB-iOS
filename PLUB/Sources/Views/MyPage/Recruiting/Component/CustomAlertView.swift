//
//  CustomAlertView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/19.
//
import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

struct AlertModel {
  let title: String // 알림창 제목
  let message: String? // 알림창 내용
  let cancelButton: String? // 취소 버튼 이름
  let confirmButton: String? // 확인 버튼 이름
  let height: Int? // 알림창 높이
}

final class CustomAlertView: UIView {
  private let model: AlertModel
  private let disposeBag = DisposeBag()
  
  typealias CompletionHandler = () -> Void
  private var completionHandler: CompletionHandler?
  
  private let backgroundButton = UIButton().then {
    $0.backgroundColor = .black
    $0.alpha = 0
  }
    
  private let alertView = UIStackView().then {
    $0.backgroundColor = .white
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 20
    $0.axis = .vertical
    $0.spacing = 32
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
  }
  
  private lazy var titleLabel = UILabel().then {
    $0.text = model.title
    $0.font = .h4
    $0.textColor = .main
    $0.numberOfLines = 0
    $0.textAlignment = .center
  }
  
  private lazy var messageLabel = UILabel().then {
    $0.text = model.message
    $0.font = .body2
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.textAlignment = .center
  }
  
  private let buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 12
    $0.isLayoutMarginsRelativeArrangement = true
    $0.distribution = .fillEqually
  }
  
  private lazy var cancelButton = UIButton(configuration: .plain()).then {
    $0.configuration?.title = model.cancelButton
    $0.configuration?.font = .button
    $0.configuration?.background.backgroundColor = .lightGray
    $0.configuration?.background.cornerRadius = 10
    $0.configuration?.baseForegroundColor = .deepGray
  }
  
  private lazy var confirmButton =  UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: model.confirmButton ?? "")
  }
  
  init(
    _ model: AlertModel,
    completionHandler: CompletionHandler?
  ) {
    self.model = model
    self.completionHandler = completionHandler
    super.init(frame: .zero)

    setupLayouts()
    setupConstraints()
    bind()
  }
  
  private func setupLayouts() {
    [backgroundButton, alertView].forEach {
      addSubview($0)
    }
    
    [
      titleLabel,
      model.message == nil ? nil : messageLabel,
      buttonStackView
    ].compactMap { $0 }.forEach {
      alertView.addArrangedSubview($0)
    }
    
    [
      model.cancelButton == nil ? nil : cancelButton,
      model.confirmButton == nil ? nil : confirmButton
    ].compactMap { $0 }.forEach {
      buttonStackView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    backgroundButton.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    alertView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.equalTo(296)
      if let height = model.height {
        $0.height.equalTo(height)
      }
    }
    
    buttonStackView.snp.makeConstraints {
      if let _ = model.cancelButton,
         let _ = model.confirmButton {
        $0.height.equalTo(46)
      } else {
        $0.height.equalTo(0)
      }
    }
    
    if model.message != nil {
      alertView.setCustomSpacing(8, after: titleLabel)
    }
  }
  
  private func bind() {
    cancelButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.dismiss()
      }
      .disposed(by: disposeBag)
    
    confirmButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.completionHandler?()
        owner.dismiss()
      }
      .disposed(by: disposeBag)
    
    backgroundButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.dismiss()
      }
      .disposed(by: disposeBag)
  }
    
  func show() {
    guard let keyWindow = UIApplication.shared.connectedScenes
      .filter({$0.activationState == .foregroundActive})
      .compactMap({$0 as? UIWindowScene})
      .first?.windows
      .filter({$0.isKeyWindow}).first else { return }

    keyWindow.addSubview(self)
    
    self.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    alpha = 0
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
      self.alpha = 1
      self.backgroundButton.alpha = 0.45
    }, completion: nil)
  }
    
  func dismiss() {
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
      self.alpha = 0
    }) { _ in
      self.removeFromSuperview()
    }
  }
    
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
