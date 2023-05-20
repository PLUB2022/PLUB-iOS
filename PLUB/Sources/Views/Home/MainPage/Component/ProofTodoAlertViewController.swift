//
//  ProofTodoAlertViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/17.
//

import UIKit

import Kingfisher
import Lottie
import RxSwift
import SnapKit
import Then

final class ProofTodoAlertViewController: BaseViewController {
  
  private let dimmedView = UIView().then {
    $0.backgroundColor = .black.withAlphaComponent(0.45)
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 14
    $0.alignment = .center
    $0.backgroundColor = .white
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 30
    $0.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: .zero, bottom: 12, right: .zero)
  }
  
  private let animationView = LottieAnimationView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.animation = .named("CreateMeeting")
    $0.play()
  }
  
  private let successGoalLabel = UILabel().then {
    $0.text = "목표 완료!"
    $0.textColor = .main
    $0.font = .systemFont(ofSize: 24, weight: .semibold)
  }
  
  private let alertLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14, weight: .regular)
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.text = "“중요한건 꺾이지 않는 마음”\n 목표 달성까지 그 마음 잊지 마세요!"
    $0.textAlignment = .center
  }
  
  private let tapGesture = UITapGestureRecognizer(target: ProofTodoAlertViewController.self, action: nil)
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // curveEaseOut: 시작은 천천히, 끝날 땐 빠르게
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut) { [weak self] in
      self?.containerView.transform = .identity
      self?.containerView.isHidden = false
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // curveEaseIn: 시작은 빠르게, 끝날 땐 천천히
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn) { [weak self] in
      self?.containerView.transform = .identity
      self?.containerView.isHidden = true
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    dimmedView.addGestureRecognizer(tapGesture)
  }
  
  override func bind() {
    super.bind()
    tapGesture.rx.event
      .subscribe(with: self) { owner, _ in
        owner.dismiss(animated: false)
      }
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(dimmedView)
    dimmedView.addSubview(containerView)
    [animationView, successGoalLabel, alertLabel].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    dimmedView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.width.equalTo(296)
      $0.height.equalTo(376)
      $0.center.equalToSuperview()
    }
    
    containerView.setCustomSpacing(0, after: animationView)
  }
}
