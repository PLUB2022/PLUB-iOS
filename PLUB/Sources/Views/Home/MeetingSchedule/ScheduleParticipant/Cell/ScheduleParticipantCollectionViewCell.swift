//
//  ScheduleParticipantCollectionViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/07.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class ScheduleParticipantCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "ScheduleParticipantCollectionViewCell"
  
  private let participantImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 20
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.backgroundColor = .background
    [participantImageView].forEach { contentView.addSubview($0) }
    participantImageView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.size.equalTo(40)
    }
  }
  
  public func configureUI(with model: ParticipantCollectionViewCellModel) {
    guard let url = URL(string: model.imageName) else { return }
    participantImageView.kf.setImage(with: url)
  }
}
