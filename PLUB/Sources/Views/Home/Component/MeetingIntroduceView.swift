//
//  MeetingIntroduceView.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/18.
//

import UIKit

import SnapKit
import Then

struct MeetingIntroduceModel {
  let title: String
  let introduce: String
}

class MeetingIntroduceView: UIView {
  
  private let meetingIntroduceLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 18)
    $0.textColor = .black
    $0.sizeToFit()
  }
  
  private let meetingDescriptionLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14)
    $0.textAlignment = .justified
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.sizeToFit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [meetingIntroduceLabel, meetingDescriptionLabel].forEach { addSubview($0) }
    meetingIntroduceLabel.snp.makeConstraints {
      $0.top.left.equalToSuperview()
    }
    
    meetingDescriptionLabel.snp.makeConstraints {
      $0.top.equalTo(meetingIntroduceLabel.snp.bottom).offset(16)
      $0.left.right.bottom.equalToSuperview()
      $0.width.equalTo(Device.width)
    }
  }
  
  public func configureUI(with model: MeetingIntroduceModel) {
    meetingIntroduceLabel.text = "[ \(model.title) ] 모임은요...!"
    meetingDescriptionLabel.text = model.introduce
  }
}
