//
//  IntroduceCategoryTitleView.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/18.
//

import UIKit

import SnapKit
import Then

struct IntroduceCategoryTitleViewModel {
  let title: String
  let name: String
  let infoText: String
}

final class IntroduceCategoryTitleView: UIView {
  
  private(set) var meetingTitle: String?
  
  private let meetingTitleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 18)
    $0.textAlignment = .left
    $0.sizeToFit()
  }
  
  private let introduceTitleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .h3
    $0.textAlignment = .left
    $0.sizeToFit()
  }
  
  private let locationInfoView = CategoryInfoView(categoryType: .location)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [meetingTitleLabel, introduceTitleLabel, locationInfoView].forEach { addSubview($0) }
    
    meetingTitleLabel.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.width.equalTo(Device.width)
    }
    
    introduceTitleLabel.snp.makeConstraints {
      $0.top.equalTo(meetingTitleLabel.snp.bottom)
      $0.leading.equalToSuperview()
    }
    
    locationInfoView.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.top.equalTo(introduceTitleLabel.snp.bottom)
      $0.height.equalTo(18)
      $0.bottom.equalToSuperview()
    }
  }
  
  func configureUI(with model: IntroduceCategoryTitleViewModel) {
    meetingTitle = model.title
    meetingTitleLabel.text = model.title
    introduceTitleLabel.text = model.name
    
    if model.infoText.isEmpty {
      locationInfoView.snp.updateConstraints {
        $0.height.equalTo(0)
      }
    } else {
      locationInfoView.configureUI(with: model.infoText, categoryListType: .onlyLocation)
    }
  }
}
