//
//  MeetingCollectionViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/02.
//

import UIKit

import SnapKit

struct MeetingCellModel {
  let plubbing: MyPlubbing?
  var isDimmed: Bool
}

final class MeetingCollectionViewCell: UICollectionViewCell {
  static let identifier = "MeetingCollectionViewCell"
  
  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
  }
  
  private let textStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 16
    $0.alignment = .center
  }
  
  private let goalView = UIView()
  
  private let goalLabel = UILabel().then {
    $0.textColor = .main
    $0.font = .appFont(family: .nanum, size: 32)
    $0.textAlignment = .center
  }
  
  private let goalBackgroundView = UIView().then {
    $0.backgroundColor = .subMain
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .h2
    $0.textColor = .black
  }
  
  private let dateLabel = UILabel().then {
    $0.font = .caption
    $0.textColor = .black
  }
  
  private let dimmedView = UIView().then {
    $0.backgroundColor = UIColor(hex: 0xFAF9FE, alpha: 0.45)
    $0.translatesAutoresizingMaskIntoConstraints = false
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
    imageView.image = nil
    titleLabel.text = nil
    dateLabel.text = nil
    goalLabel.text = nil
    dimmedView.isHidden = false
  }
    
  private func setupLayouts() {
    [imageView, textStackView, dimmedView].forEach {
      addSubview($0)
    }
  
    [goalView, titleLabel, dateLabel].forEach {
      textStackView.addArrangedSubview($0)
    }
    
    [goalBackgroundView, goalLabel].forEach {
      goalView.addSubview($0)
    }
  }
    
  private func setupConstraints() {
    imageView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(270)
    }
    
    textStackView.snp.makeConstraints {
      $0.top.equalTo(imageView.snp.bottom).offset(16)
      $0.leading.trailing.equalToSuperview()
    }
    
    goalView.snp.makeConstraints {
      $0.height.equalTo(40)
    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(33)
    }
    
    dateLabel.snp.makeConstraints {
      $0.height.equalTo(18)
    }
    
    dimmedView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    textStackView.setCustomSpacing(8, after: titleLabel)
    
    goalBackgroundView.snp.makeConstraints {
      $0.width.equalTo(187)
      $0.height.equalTo(19)
      $0.centerX.bottom.equalToSuperview()
    }
    
    goalLabel.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupStyles() {
    backgroundColor = .clear
    
    layer.cornerRadius = 30
    layer.borderWidth = 1
    layer.borderColor = UIColor.main.cgColor
  }
  
  func setupData(with data: MeetingCellModel) {
    guard let plubbing = data.plubbing else { return }
    titleLabel.text = plubbing.name
    goalLabel.text = plubbing.goal
    
    dateLabel.text = plubbing.days
      .map{ $0.fromENGToKOR() }
      .joined(separator: " ,")
    
    dimmedView.isHidden = !data.isDimmed
    
    if let imageURL = plubbing.mainImage, let url = URL(string: imageURL) {
      imageView.kf.setImage(with: url)
    } else {
      imageView.image = nil
    }
    
    imageView.layer.cornerRadius = 30
    imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

    imageView.layer.masksToBounds = true
  }
}
