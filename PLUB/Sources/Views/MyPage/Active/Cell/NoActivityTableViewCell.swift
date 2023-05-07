//
//  NoActivityTableViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/05/07.
//

import UIKit

import SnapKit
import Then

final class NoActivityTableViewCell: UITableViewCell {
  static let identifier = "NoActivityTableViewCell"
  
  private let button = UIButton().then {
    $0.backgroundColor = .lightGray
    $0.layer.cornerRadius = 10
    $0.titleLabel?.font = .button
    $0.setTitleColor(.deepGray, for: .normal)
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    contentView.addSubview(button)
  }
  
  private func setupConstraints() {
    button.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview().inset(17)
      $0.top.equalToSuperview()
      $0.bottom.equalToSuperview().inset(8)
      $0.height.equalTo(48)
    }
  }
  
  private func setupStyles() {
    backgroundColor = .background
    selectionStyle = .none
  }
  
  func setupData(type: MyActivityType) {
    button.setTitle(type.noneText, for: .normal)
  }
}
