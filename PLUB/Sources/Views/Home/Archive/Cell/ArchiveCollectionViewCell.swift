//
//  ArchiveCollectionViewCell.swift
//  PLUB
//
//  Created by 홍승현 on 2023/03/10.
//

import UIKit

import Kingfisher
import RxSwift
import RxCocoa
import SnapKit
import Then

final class ArchiveCollectionViewCell: UICollectionViewCell {
  
  // MARK: - Properties
  
  static let identifier = "\(ArchiveCollectionViewCell.self)"
  
  // MARK: - UI Components
  
  // MARK: Leading Indicator Part
  
  private let leadingIndicatorStackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .center
  }
  
  private let circleImageView = UIImageView(image: .init(named: "pointWhite")).then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let verticalLineView = UIView().then {
    $0.backgroundColor = .lightGray
  }
  
  // MARK: Content Part
  
  /// 하얀 배경으로 여러 정보를 담고 있는 뷰(이미지, 타이틀, 날짜 등)
  private let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 10
  }
  
  private let firstContentImageView = UIImageView().then {
    $0.backgroundColor = .deepGray
    $0.layer.cornerRadius = 6
    $0.clipsToBounds = true
    $0.isHidden = true
  }
  private let secondContentImageView = UIImageView().then {
    $0.backgroundColor = .deepGray
    $0.alpha = 0.5
    $0.layer.cornerRadius = 6
    $0.clipsToBounds = true
    $0.isHidden = true
  }
  private let thirdContentImageView = UIImageView().then {
    $0.backgroundColor = .deepGray
    $0.alpha = 0.1
    $0.layer.cornerRadius = 6
    $0.clipsToBounds = true
    $0.isHidden = true
  }
  
  private let photoCountInformationStackView = UIStackView().then {
    $0.spacing = 2
    $0.alignment = .center
  }
  
  private let photoCountImageView = UIImageView(image: .init(named: "photoLibrary")).then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let photoCountLabel = UILabel().then {
    $0.text = "0"
    $0.textColor = .white
    $0.font = .caption2
  }
  
  private let settingButton = UIButton().then {
    $0.setImage(.init(named: "meatballMenu"), for: .normal)
    $0.imageView?.contentMode = .scaleAspectFit
  }
  
  private let titleStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
    $0.alignment = .leading
  }
  
  private let datetimeLabel = UILabel().then {
    $0.text = "XX번째 기록 | 2022. 03. 25"
    $0.textColor = .mediumGray
    $0.font = .overLine
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "모임 아카이브 타이틀"
    $0.textColor = .black
    $0.font = .button
  }
  
  // MARK: - Initializations
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  private func setupLayouts() {
    contentView.addSubview(leadingIndicatorStackView)
    contentView.addSubview(containerView)
    
    [circleImageView, verticalLineView].forEach {
      leadingIndicatorStackView.addArrangedSubview($0)
    }
    
    // add image Views to `containerView`
    [thirdContentImageView, secondContentImageView, firstContentImageView].forEach {
      containerView.addSubview($0)
    }
    // add photo's count view to firstContentImageView
    firstContentImageView.addSubview(photoCountInformationStackView)
    
    [photoCountImageView, photoCountLabel].forEach {
      photoCountInformationStackView.addArrangedSubview($0)
    }
    
    [titleStackView, settingButton].forEach {
      containerView.addSubview($0)
    }
    
    [datetimeLabel, titleLabel].forEach {
      titleStackView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    leadingIndicatorStackView.snp.makeConstraints {
      $0.leading.top.bottom.equalToSuperview()
    }
    
    circleImageView.snp.makeConstraints {
      $0.size.equalTo(10)
    }
    
    verticalLineView.snp.makeConstraints {
      $0.width.equalTo(2)
    }
    
    containerView.snp.makeConstraints {
      $0.top.trailing.equalToSuperview()
      $0.leading.equalTo(leadingIndicatorStackView.snp.trailing).offset(8)
      $0.bottom.equalToSuperview().inset(8)
    }
    
    // images
    firstContentImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(8)
      $0.centerY.equalToSuperview()
      $0.size.equalTo(80)
    }
    
    secondContentImageView.snp.makeConstraints {
      $0.leading.equalTo(firstContentImageView.snp.leading).offset(12)
      $0.centerY.equalTo(firstContentImageView)
      $0.size.equalTo(firstContentImageView.snp.size).offset(-8) // 첫 번째 이미지에서 8을 뺀 크기
    }
    
    thirdContentImageView.snp.makeConstraints {
      $0.leading.equalTo(secondContentImageView.snp.leading).offset(12)
      $0.centerY.equalTo(firstContentImageView)
      $0.size.equalTo(secondContentImageView.snp.size).offset(-8) // 두 번째 이미지에서 8을 뺀 크기
    }
    
    // photo count
    photoCountInformationStackView.snp.makeConstraints {
      $0.leading.bottom.equalToSuperview().inset(6)
    }
    
    photoCountImageView.snp.makeConstraints {
      $0.size.equalTo(16)
    }
    
    titleStackView.snp.makeConstraints {
      $0.leading.equalTo(firstContentImageView.snp.trailing).offset(24)
      $0.bottom.equalTo(firstContentImageView.snp.bottom).inset(2) // 첫 번째 이미지 bottom을 기준으로 함
    }
    
    settingButton.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.trailing.equalToSuperview().inset(4)
      $0.size.equalTo(32)
    }
  }
  
  private func setupStyles() {
    
  }
  
  func configure(with model: ArchiveContent) {
    guard let date = DateFormatterFactory.dateWithHypen.date(from: model.postDate) else {
      return
    }
    let dateString = DateFormatterFactory.dateWithDot.string(from: date)
    datetimeLabel.text = "\(model.sequence)번째 기록 | \(dateString)"
    titleLabel.text = model.title
    photoCountLabel.text = "\(model.imageCount)"
    
    let imageViews = [firstContentImageView, secondContentImageView, thirdContentImageView]
    
    for (imageView, urlString) in zip(imageViews, model.images) {
      imageView.isHidden = false
      imageView.kf.setImage(with: URL(string: urlString))
    }
  }
  
  
  override func prepareForReuse() {
    super.prepareForReuse()
    secondContentImageView.isHidden = true
    thirdContentImageView.isHidden = true
  }
}
