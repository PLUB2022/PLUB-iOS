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
  func didTappedMoreButton()
}

class ParticipantListView: UIView {
  
  weak var delegate: ParticipantListViewDelegate?
  
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
    $0.titleLabel?.textAlignment = .center
    $0.layer.masksToBounds = true
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
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let moreButtonSize = moreButton.bounds.size
    moreButton.layer.cornerRadius = moreButtonSize.height / 2.0
  }
  
  private func configureUI() {
    [participantTitleLabel, participantListStackView].forEach { addSubview($0) }
    
    participantTitleLabel.snp.makeConstraints {
      $0.top.left.equalToSuperview()
    }
    
    participantListStackView.snp.makeConstraints {
      $0.top.equalTo(participantTitleLabel.snp.bottom).offset(7)
      $0.left.bottom.equalToSuperview()
      $0.right.lessThanOrEqualToSuperview()
    }
    
    moreButton.snp.makeConstraints {
      $0.size.equalTo(34)
    }

    moreButton.addTarget(self, action: #selector(didTappedMoreButton), for: .touchUpInside)
  }
  
  public func configureUI(with model: [AccountInfo]) {
    let joinedCount = model.count
    guard joinedCount > 0 else { return }
    if joinedCount <= 8 {
      model.forEach { account in
        let participantImageView = ParticipantImageView(frame: .zero)
        participantImageView.configureUI(with: account.profileImage)
        participantListStackView.addArrangedSubview(participantImageView)
      }
    }
    else { // 9명 이상일때
      let moreCount = joinedCount - 7
      moreButton.isHidden = false
      moreButton.setTitle("+\(moreCount)", for: .normal)
      for index in 0..<7 {
        let participantImageView = ParticipantImageView(frame: .zero)
        participantImageView.configureUI(with: model[index].profileImage)
        participantListStackView.addArrangedSubview(participantImageView)
      }
      participantListStackView.addArrangedSubview(moreButton)
      moreButton.layoutIfNeeded()
    }
  }
  
  @objc private func didTappedMoreButton() {
    delegate?.didTappedMoreButton()
  }
}

class ParticipantImageView: UIImageView {
  override init(frame: CGRect) {
    super.init(frame: .zero)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let imageSize = self.bounds.size
    layer.cornerRadius = imageSize.width / 2.0
  }
  
  private func configureUI() {
    layer.masksToBounds = true
    contentMode = .scaleAspectFit
    image = UIImage(systemName: "person.fill")
    backgroundColor = .yellow
    snp.makeConstraints {
      $0.size.equalTo(34)
    }
  }
  
  public func configureUI(with model: String?) {
    guard let url = URL(string: model ?? "") else { return }
    kf.setImage(with: url)
  }
}
