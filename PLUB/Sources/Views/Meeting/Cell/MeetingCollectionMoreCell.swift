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
    dimmedView.isHidden = false
  }
    
  private func setupLayouts() {
    [imageView, titleLabel, dimmedView].forEach {
      addSubview($0)
    }
  }
    
  private func setupConstraints() {
    imageView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(163)
      $0.size.equalTo(40)
      $0.centerX.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(imageView.snp.bottom).offset(23)
      $0.centerX.equalToSuperview()
      $0.leading.trailing.equalToSuperview()
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
  
  func setupData(isDimmed: Bool) {
    dimmedView.isHidden = !isDimmed
  }
}
