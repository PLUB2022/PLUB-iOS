//
//  ArchivePopUpViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/14.
//

import UIKit

import SnapKit
import Then

final class ArchivePopUpViewController: BaseViewController {
  
  // MARK: - UI Components
  
  /// 모달 뷰
  private let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 20
  }
  
  /// 닫기 버튼
  private let closeButton = UIButton().then {
    $0.setImage(.init(named: "xMarkDeepGray"), for: .normal)
  }
  
  // MARK: - Initializations
  
  init() {
    super.init(nibName: nil, bundle: nil)
    
    // popup motion 적용
    modalTransitionStyle = .crossDissolve
    modalPresentationStyle = .overFullScreen
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(containerView)
    
    [closeButton].forEach {
      containerView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview().inset(24)
      $0.height.equalTo(440)
      $0.center.equalToSuperview()
    }
    
    closeButton.snp.makeConstraints {
      $0.top.trailing.equalToSuperview().inset(7)
      $0.size.equalTo(32)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .black.withAlphaComponent(0.45)
  }
  
  override func bind() {
    super.bind()
    
    closeButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
  }
}
