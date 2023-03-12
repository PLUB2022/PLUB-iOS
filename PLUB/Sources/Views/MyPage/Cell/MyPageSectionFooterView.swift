//
//  MyPageSectionFooterView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/12.
//
import UIKit

final class MyPageSectionFooterView: UITableViewHeaderFooterView {
  static let identifier = "MyPageSectionFooterView"

  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 0
  }
  
  private let clearView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  private let whiteView = UIView().then {
    $0.backgroundColor = .white
  }
 
  override init(reuseIdentifier: String?) {
      super.init(reuseIdentifier: reuseIdentifier)
    setupLayouts()
    setupConstraints()
    setupStyles()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    containerView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 15)
    containerView.layer.addBorder([.bottom], color: .init(hex: 0xF2F3F4), width: 1)
  }
  
  private func setupLayouts() {
    addSubview(containerView)
    
    [clearView, whiteView].forEach {
      containerView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    containerView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.top.equalToSuperview().offset(-8)
      $0.bottom.equalToSuperview()
    }
    
    clearView.snp.makeConstraints {
      $0.height.equalTo(8)
    }
  }
  
  private func setupStyles() {
  }
  
  private func bind() {
  }
}
