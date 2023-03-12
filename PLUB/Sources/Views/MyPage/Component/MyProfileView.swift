//
//  MyProfileView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/12.
//

import UIKit

import SnapKit

final class MyProfileView: UIView {
  
  private let profileImageView = UIImageView().then {
    $0.layer.cornerRadius = 32
  }
  
  private let editButton = UIButton().then {
    $0.setImage(UIImage(named: "pencil"), for: .normal)
  }
  
  private let textStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 7
  }
  
  private let userNameLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .h2
  }
  
  private let introduceLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .body2
    $0.numberOfLines = 0
  }

  init() {
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private extension MyProfileView {
  private func setupLayouts() {
    [profileImageView, editButton, textStackView].forEach {
      addSubview($0)
    }

    [userNameLabel, introduceLabel].forEach {
      textStackView.addArrangedSubview($0)
    }
  }

  private func setupConstraints() {
    profileImageView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(8)
      $0.leading.bottom.equalToSuperview().inset(16)
      $0.size.equalTo(64)
    }

    editButton.snp.makeConstraints {
      $0.top.equalTo(profileImageView.snp.top).offset(38)
      $0.leading.equalTo(profileImageView.snp.leading).offset(40)
      $0.size.equalTo(32)
    }

    textStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(15)
      $0.leading.equalTo(profileImageView.snp.trailing).offset(21)
      $0.trailing.equalToSuperview().inset(24)
    }

    userNameLabel.snp.makeConstraints {
      $0.height.equalTo(33)
    }
  }
}

extension MyProfileView {
  func setupMyProfile(with model: MyInfoResponse) {
    if let imageURL = model.profileImage, let url = URL(string: imageURL) {
      profileImageView.kf.setImage(with: url)
    } else {
      profileImageView.image = UIImage(named: "userDefaultImage")
    }
    userNameLabel.text = model.nickname
    introduceLabel.text = model.introduce
  }
}
