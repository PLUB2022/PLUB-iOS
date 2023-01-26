//
//  ParticipantListView.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/18.
//

import UIKit

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
    $0.layer.masksToBounds = true
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
    let moreButtonSize = moreButton.frame.size
    moreButton.layer.cornerRadius = moreButtonSize.width / 2
  }
  
  private func configureUI() {
    [participantTitleLabel, participantListStackView].forEach { addSubview($0) }
    
    participantTitleLabel.snp.makeConstraints {
      $0.top.left.equalToSuperview()
    }
    
    participantListStackView.snp.makeConstraints {
      $0.top.equalTo(participantTitleLabel.snp.bottom).offset(7)
      $0.left.right.bottom.equalToSuperview()
    }
    
    moreButton.snp.makeConstraints {
      $0.width.height.equalTo(34)
    }

    moreButton.addTarget(self, action: #selector(didTappedMoreButton), for: .touchUpInside)
  }
  
  public func configureUI(with model: [AccountInfo]) {
    let joinedCount = model.count
    guard joinedCount < 1 else { return }
    if joinedCount <= 8 {
      
    } else { // 9명 이상일때
      
    }
  }
  
  @objc private func didTappedMoreButton() {
    delegate?.didTappedMoreButton()
  }
}

final class ParticipantImageView: UIImageView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let imageSize = self.bounds.size.width
    layer.cornerRadius = imageSize / 2
  }
  
  private func configureUI() {
    layer.masksToBounds = true
    contentMode = .scaleAspectFit
    image = UIImage(systemName: "person.fill")
    backgroundColor = .yellow
    snp.makeConstraints { make in
      make.size.equalTo(34)
    }
  }
}
