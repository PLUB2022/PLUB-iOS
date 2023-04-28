//
//  IntroduceCategoryInfoView.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/18.
//

import UIKit

import SnapKit
import Then

struct IntroduceCategoryInfoViewModel {
  let recommendedText: String
  let meetingImageURL: String? // 이미지 URL
  let meetingImage: UIImage? // 원본 이미지
  let categoryInfoListModel: CategoryInfoListModel
}

final class IntroduceCategoryInfoView: UIView {
  
  private let meetingRecommendedLabel = UILabel().then {
    $0.font = .appFont(family: .nanum, size: 32)
    $0.textColor = .main
    $0.textAlignment = .center
    $0.sizeToFit()
  }
  
  private let categoryInfoListView = CategoryInfoListView(
    categoryAlignment: .horizontal,
    categoryListType: .noLocation
  )
  
  private let meetingImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [meetingRecommendedLabel, categoryInfoListView, meetingImageView].forEach { addSubview($0) }
    meetingRecommendedLabel.snp.makeConstraints {
      $0.directionalHorizontalEdges.top.equalToSuperview()
      $0.height.equalTo(40)
    }
    
    categoryInfoListView.snp.makeConstraints {
      $0.top.equalTo(meetingRecommendedLabel.snp.bottom).offset(24)
      $0.leading.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
      $0.height.equalTo(16)
    }
    
    meetingImageView.snp.makeConstraints {
      $0.top.equalTo(categoryInfoListView.snp.bottom).offset(8)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
      $0.height.equalTo(246)
    }
  }
  
  func configureUI(with model: IntroduceCategoryInfoViewModel) {
    meetingRecommendedLabel.text = model.recommendedText
    categoryInfoListView.configureUI(with: model.categoryInfoListModel)
    
    if let urlStr = model.meetingImageURL, let url = URL(string: urlStr) {
      meetingImageView.kf.setImage(with: url)
    } else if let image = model.meetingImage {
      meetingImageView.image = image
      let width = Device.width - 16 * 2
      meetingImageView.snp.remakeConstraints {
        $0.top.equalTo(categoryInfoListView.snp.bottom).offset(24)
        $0.leading.trailing.bottom.equalToSuperview()
        $0.height.equalTo(width * image.size.height / image.size.width)
      }
    }
  }
}
