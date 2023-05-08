//
//  MeetingCollectionMoreCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/26.
//

import UIKit

import SnapKit

final class MeetingCollectionMoreCell: UICollectionViewCell {
  static let identifier = "MeetingCollectionMoreCell"
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 23
    $0.alignment = .center
  }
  
  private let imageView = UIImageView().then {
    $0.image = UIImage(named: "plusCircle")
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .h5
    $0.textColor = .deepGray
    $0.textAlignment = .center
    $0.numberOfLines = 0
    $0.text = """
    새로운 모임에
    참여해 보세요!
    """
  }
  
  private let dimmedView = UIView().then {
    $0.backgroundColor = .background.withAlphaComponent(0.45)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    dimmedView.isHidden = false
  }
    
  private func setupLayouts() {
    [contentStackView, dimmedView].forEach {
      contentView.addSubview($0)
    }
    
    [imageView, titleLabel].forEach {
      contentStackView.addArrangedSubview($0)
    }
  }
    
  private func setupConstraints() {
    contentStackView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
    
    imageView.snp.makeConstraints {
      $0.size.equalTo(40)
    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(50)
    }
    
    dimmedView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupStyles() {
    backgroundColor = .lightGray
    
    layer.cornerRadius = 30
    layer.borderWidth = 1
    layer.borderColor = UIColor.main.cgColor
  }
  
  func setupData(with model: MeetingCellModel) {
    dimmedView.isHidden = !model.isDimmed
    titleLabel.text = model.isHost ? Constants.createMeeting : Constants.joinMeeting
  }
}

extension MeetingCollectionMoreCell {
  private enum Constants {
    static let joinMeeting = """
    새로운 모임에
    참여해 보세요!
    """
    static let createMeeting = """
    새로운 모임을
    만들어 보세요!
    """
  }
}
