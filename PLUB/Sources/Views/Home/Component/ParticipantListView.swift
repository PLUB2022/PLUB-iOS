//
//  ParticipantListView.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/18.
//

import UIKit

import Kingfisher
import SnapKit
import Then

protocol ParticipantListViewDelegate: AnyObject {
  func didTappedMoreButton(accountInfos: [AccountInfo])
}

final class ParticipantListView: UIView {
  
  weak var delegate: ParticipantListViewDelegate?
  var accountInfos: [AccountInfo]?
  
  private let participantTitleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .h5
    $0.textAlignment = .justified
    $0.text = "With us!"
    $0.sizeToFit()
  }
  
  private let participantListStackView = UIStackView().then {
    $0.spacing = 8.05
    $0.axis = .horizontal
    $0.alignment = .leading
  }
  
  private let moreButton = UIButton().then {
    $0.backgroundColor = .lightGray
    $0.tintColor = .deepGray
    $0.titleLabel?.font = .overLine
    $0.titleLabel?.textAlignment = .center
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 17
    $0.clipsToBounds = true
    $0.isHidden = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [participantTitleLabel, participantListStackView].forEach { addSubview($0) }
    
    participantTitleLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
    }
    
    participantListStackView.snp.makeConstraints {
      $0.top.equalTo(participantTitleLabel.snp.bottom).offset(7)
      $0.leading.bottom.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
    
    moreButton.snp.makeConstraints {
      $0.size.equalTo(34)
    }
    
    moreButton.addTarget(self, action: #selector(didTappedMoreButton), for: .touchUpInside)
  }
  
  private func addElement(model: AccountInfo) {
    let participantImageView = ParticipantImageView(frame: .zero)
    participantImageView.configureUI(with: model.profileImage)
    participantListStackView.addArrangedSubview(participantImageView)
  }
  
  func configureUI(with model: [AccountInfo]) {
    participantListStackView.subviews.forEach { $0.removeFromSuperview() }
    accountInfos = model
    let model = model.compactMap { $0 }
    let joinedCount = model.count
    guard joinedCount > 0 else { return }
    if joinedCount <= 8 {
      model.forEach { account in
        addElement(model: account)
      }
    }
    else { // 9명 이상일때
      let moreCount = joinedCount - 7
      moreButton.isHidden = false
      moreButton.setTitle("+\(moreCount)", for: .normal)
      for index in 0..<7 {
        addElement(model: model[index])
      }
      participantListStackView.addArrangedSubview(moreButton)
      moreButton.layoutIfNeeded()
    }
  }
  
  @objc private func didTappedMoreButton() {
    guard let accountInfos = accountInfos else { return }
    delegate?.didTappedMoreButton(accountInfos: accountInfos)
  }
}

final class ParticipantImageView: UIImageView {
  override init(frame: CGRect) {
    super.init(frame: .zero)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    layer.masksToBounds = true
    layer.cornerRadius = 17
    image = UIImage(named: "userDefaultImage")
    contentMode = .scaleAspectFill
    snp.makeConstraints {
      $0.size.equalTo(34)
    }
  }
  
  func configureUI(with model: String?) {
    guard let url = URL(string: model ?? "") else { return }
    kf.setImage(with: url)
  }
}
