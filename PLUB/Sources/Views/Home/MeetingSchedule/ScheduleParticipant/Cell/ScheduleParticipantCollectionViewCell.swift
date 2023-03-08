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

enum ScheduleParticipantCellType {
  case participant
  case moreParticipant(Int)
}

final class ScheduleParticipantCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "ScheduleParticipantCollectionViewCell"
  
  private let participantImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 20
  }
  
  private let moreParticipantView = UIView().then {
    $0.layer.cornerRadius = 20
    $0.backgroundColor = .lightGray
    $0.isHidden = true
  }
  
  private let moreParticipantLabel = UILabel().then {
    $0.font = .subtitle
    $0.textColor = .black
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    participantImageView.image = nil
    moreParticipantLabel.text = nil
  }
  
  private func configureUI() {
    contentView.backgroundColor = .background
    [participantImageView, moreParticipantView].forEach {
      contentView.addSubview($0)
      $0.snp.makeConstraints {
        $0.center.equalToSuperview()
        $0.size.equalTo(40)
      }
    }

    moreParticipantView.addSubview(moreParticipantLabel)
    moreParticipantLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  public func configureUI(
    with model: ParticipantCollectionViewCellModel,
    type: ScheduleParticipantCellType
  ) {
    switch type {
    case .participant:
      moreParticipantView.isHidden = true
      guard let url = URL(string: model.imageName) else { return }
      participantImageView.kf.setImage(with: url)
      
    case .moreParticipant(let count):
      moreParticipantView.isHidden = false
      moreParticipantLabel.text = "+\(count)"
    }
  }
}
