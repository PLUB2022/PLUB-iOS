//
//  ParticipantListCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/17.
//

import UIKit

import SnapKit
import Then

final class ParticipantListCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "ParticipantListCollectionViewCell"
  
  private let profileImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.image = UIImage(systemName: "person.fill")
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
    let contentViewWidth = contentView.frame.width
    contentView.layer.cornerRadius = contentViewWidth / 2
  }
  
  private func configureUI() {
    contentView.addSubview(profileImageView)
    contentView.layer.masksToBounds = true
    contentView.backgroundColor = .orange
    profileImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    
  }
}
