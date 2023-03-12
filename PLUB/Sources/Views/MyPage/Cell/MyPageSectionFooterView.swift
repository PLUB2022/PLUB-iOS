//
//  MyPageSectionFooterView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/12.
//
import UIKit

final class MyPageSectionFooterView: UITableViewHeaderFooterView {
  static let identifier = "MyPageSectionFooterView"

  private let containerView = UIView().then {
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
  
  private func setupLayouts() {
    addSubview(containerView)
  }
  
  private func setupConstraints() {
    containerView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.top.bottom.equalToSuperview()
    }
  }
  
  private func setupStyles() {
  }
  
  private func bind() {
  }
}
