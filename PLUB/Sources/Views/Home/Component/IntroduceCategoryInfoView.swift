//
//  IntroduceCategoryInfoView.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/18.
//

import UIKit

import SnapKit
import Then

class IntroduceCategoryInfoView: UIView {
  
  private let meetingRecommendedLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 32)
    $0.textColor = .main
    $0.text = "“스트레칭은 20분 이상”"
    $0.textAlignment = .center
    $0.sizeToFit()
  }
  
  private let categoryInfoListView = CategoryInfoListView(categoryInfoListViewType: .horizontal).then {
    $0.backgroundColor = .red
  }
  
  private let meetingImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.image = UIImage(named: "selectImage")
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
    categoryInfoListView.configureUI(with: .init(location: "서울 서초구", peopleCount: 10, when: "매주 금요일 | 오후 5시 30분"))
    meetingRecommendedLabel.snp.makeConstraints {
      $0.left.top.right.equalToSuperview()
    }
    
    categoryInfoListView.snp.makeConstraints {
      $0.top.equalTo(meetingRecommendedLabel.snp.bottom)
      $0.centerX.equalToSuperview()
    }
    
    meetingImageView.snp.makeConstraints {
      $0.top.equalTo(categoryInfoListView.snp.bottom)
      $0.left.right.bottom.equalToSuperview()
    }
  }
}
