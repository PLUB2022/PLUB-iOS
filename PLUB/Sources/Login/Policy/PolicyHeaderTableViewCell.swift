//
//  PolicyHeaderTableViewCell.swift
//  PLUB
//
//  Created by 홍승현 on 2022/12/10.
//

import UIKit

import SnapKit
import Then

final class PolicyHeaderTableViewCell: UITableViewCell {
  
  static let identifier = "\(PolicyHeaderTableViewCell.self)"
  
  private let disclosureIndicator: UIImageView = UIImageView().then {
    $0.image = UIImage(systemName: "chevron.down")
    $0.contentMode = .scaleAspectFit
    $0.tintColor = .deepGray
  }
  
  private let policyLabel: UILabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = .body2
    $0.textColor = .deepGray
  }
  
  private let checkbox: CheckBoxButton = CheckBoxButton(type: .full)
  
  private let stackView: UIStackView = UIStackView().then {
    $0.spacing = 2
    $0.alignment = .center
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    contentView.addSubview(stackView)
    [disclosureIndicator, policyLabel, checkbox].forEach {
      stackView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalTo(48)
    }
    
    disclosureIndicator.snp.makeConstraints { make in
      make.size.equalTo(24)
    }
    
    checkbox.snp.makeConstraints { make in
      make.size.equalTo(24)
    }
  }
  
  func configure(with policy: String) {
    policyLabel.text = policy
  }
}
