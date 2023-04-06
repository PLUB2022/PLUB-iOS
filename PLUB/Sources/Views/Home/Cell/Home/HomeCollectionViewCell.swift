//
//  HomeCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/10/06.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class HomeCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "HomeCollectionViewCell"
  
  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let interestLabel = UILabel().then {
    $0.font = .caption
    $0.textColor = .black
    $0.textAlignment = .center
    $0.sizeToFit()
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
    imageView.image = nil
    interestLabel.text = nil
  }
  
  private func configureUI() {
    contentView.backgroundColor = .background
    contentView.layer.masksToBounds = true
    [imageView, interestLabel].forEach { contentView.addSubview($0) }
    imageView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(64)
    }
    
    interestLabel.snp.makeConstraints {
      $0.top.equalTo(imageView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
    }
  }
  
  func configureUI(with model: MainCategory) {
    guard let url = URL(string: model.icon) else { return }
    interestLabel.text = model.name
    imageView.kf.setImage(with: url)
  }
}

