//
//  RegisterInterestHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2022/10/10.
//

import UIKit

import SnapKit
import Then

struct RegisterInterestHeaderViewModel {
  let title: String
  let description: String
}

class RegisterInterestHeaderView: UITableViewHeaderFooterView {
  
  static let identifier = "RegisterInterestHeaderView"
  
  private let titleLabel = UILabel().then {
    $0.font = .h4
    $0.textColor = .black
  }
  
  private let descriptionLabel = UILabel().then {
    $0.font = .body2
    $0.textColor = .black
    $0.numberOfLines = 0
  }
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [titleLabel, descriptionLabel].forEach { addSubview($0) }
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview()
    }
    
    descriptionLabel.snp.makeConstraints {
      $0.left.equalTo(titleLabel.snp.left)
      $0.top.equalTo(titleLabel.snp.bottom)
      $0.height.equalTo(self.snp.height).dividedBy(2)
    }
  }
  
  public func configureUI(with model: RegisterInterestHeaderViewModel) {
    titleLabel.text = model.title
    descriptionLabel.text = model.description
  }
}
