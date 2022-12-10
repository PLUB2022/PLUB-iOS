//
//  PolicyHeaderTableViewCell.swift
//  PLUB
//
//  Created by 홍승현 on 2022/12/10.
//

import UIKit

final class PolicyHeaderTableViewCell: UITableViewCell {
  
  static let identifier = "\(PolicyHeaderTableViewCell.self)"

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
