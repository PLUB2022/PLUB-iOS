//
//  MyPageTableViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/12.
//

import UIKit

import SnapKit

final class MyPageTableViewCell: UITableViewCell {
  static let identifier = "MyPageTableViewCell"
  
  //isFolded
  
  private let contentStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 16
    $0.backgroundColor = .white
    $0.alignment = .center
  }
  
  private let meetingImageView = UIImageView().then {
    $0.image = UIImage(named: "foldedArrow")
  }
  
  private let textStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 5
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .appFont(family: .pretendard(option: .bold), size: 16)
    $0.text = "당장 들어와"
  }
  
  private let subTitleLabel = UILabel().then {
    $0.font = .appFont(family: .pretendard(option: .regular), size: 12)
    $0.text = "모임 목표"
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
    addSubview(contentStackView)
    [meetingImageView, textStackView].forEach {
      contentStackView.addArrangedSubview($0)
    }
    
    [titleLabel, subTitleLabel].forEach {
      textStackView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    contentStackView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.top.bottom.equalToSuperview()
    }
    
    meetingImageView.snp.makeConstraints {
      $0.size.equalTo(56)
    }
    
//    textStackView.snp.makeConstraints {
//      $0.centerY.equalTo(meetingImageView.snp.centerY)
//      $0.leading.equalTo(meetingImageView.snp.trailing).offset(16)
//      $0.trailing.equalToSuperview().inset(16)
//    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(19)
    }
    
    subTitleLabel.snp.makeConstraints {
      $0.height.equalTo(14)
    }
  }
  
  private func setupStyles() {
    backgroundColor = .background
  }
  
  func setupRoundCorners(isFoldered: Bool) {
    contentView.roundCorners(corners: isFoldered ? [.topLeft, .topRight] : [.allCorners], radius: 15)
  }
}
