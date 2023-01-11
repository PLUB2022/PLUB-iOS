//
//  RecommendedMeetingHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2022/10/06.
//

import UIKit

import SnapKit
import Then

class RecommendedMeetingHeaderView: UICollectionReusableView {
  
  static let identifier = "RecommendedMeetingHeaderView"
  
  private let titleLabel = UILabel().then {
    $0.font = .h4
    $0.text = "플럽이 추천하는 모임!"
    $0.textColor = .black
    $0.sizeToFit()
  }
  
  private let descriptionLabel = UILabel().then {
    $0.text = "관심사 등록한 내용을 기반으로 모임을 추천해드려요!"
    $0.textColor = .deepGray
    $0.font = .caption
    $0.sizeToFit()
  }
  
  private let settingButton = UIButton().then {
    let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
    let image = UIImage(systemName: "gearshape", withConfiguration: config)
    $0.setImage(image, for: .normal)
    $0.tintColor = .black
    $0.contentMode = .scaleAspectFill
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    backgroundColor = .background
    [titleLabel, descriptionLabel, settingButton].forEach { addSubview($0) }
    descriptionLabel.snp.makeConstraints {
      $0.left.bottom.equalToSuperview()
      $0.top.equalTo(snp.centerY)
    }
    
    titleLabel.snp.makeConstraints {
      $0.left.equalToSuperview()
      $0.bottom.equalTo(snp.centerY)
    }
    
    settingButton.snp.makeConstraints {
      $0.centerY.equalTo(titleLabel)
      $0.right.equalToSuperview()
    }
}

