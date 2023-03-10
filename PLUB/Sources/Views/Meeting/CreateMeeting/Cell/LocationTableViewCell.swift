//
//  LocationTableViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/21.
//

import UIKit
import SnapKit
import Then

struct LocationTableViewCellModel {
  let title: String
  let subTitle: String
}

final class LocationTableViewCell: UITableViewCell {
    
  static let identifier = "LocationTableViewCell"
  
  private let contextView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 8
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 3
  }
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .subtitle
  }
  
  private let subTitleLabel = UILabel().then {
    $0.textColor = .mediumGray
    $0.font = .caption
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
    
  override func prepareForReuse() {
    super.prepareForReuse()
    titleLabel.text = nil
    subTitleLabel.text = nil
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    setupSelected(selected)
  }
}

private extension LocationTableViewCell {
  private func setupLayouts() {
    contentView.addSubview(contextView)
    contextView.addSubview(contentStackView)
    [titleLabel, subTitleLabel].forEach {
      contentStackView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    contextView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(4)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    contentStackView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(12)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(19)
    }
    
    subTitleLabel.snp.makeConstraints {
      $0.height.equalTo(21)
    }
  }
  
  private func setupStyles() {
    selectionStyle = .none
    accessoryType = .none
    backgroundColor = .background
  }
  
  private func setupSelected(_ selected: Bool) {
    contextView.layer.borderColor = selected ? UIColor.main.cgColor : UIColor.clear.cgColor
    contextView.layer.borderWidth = selected ? 2 : 0
  }
}

extension LocationTableViewCell {
  func setupData(with model: LocationTableViewCellModel) {
    titleLabel.text = model.title
    subTitleLabel.text = model.subTitle
  }
}
