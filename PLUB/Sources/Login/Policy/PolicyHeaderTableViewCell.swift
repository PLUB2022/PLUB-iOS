//
//  PolicyHeaderTableViewCell.swift
//  PLUB
//
//  Created by 홍승현 on 2022/12/10.
//

import UIKit

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
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
