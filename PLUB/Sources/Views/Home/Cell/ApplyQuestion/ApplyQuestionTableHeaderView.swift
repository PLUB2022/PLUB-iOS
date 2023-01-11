//
//  ApplyQuestionTableViewHeader.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/04.
//

import UIKit
import SnapKit
import Then

class ApplyQuestionTableHeaderView: UITableViewHeaderFooterView {
  
  static let identifier = "ApplyQuestionTableHeaderView"
  
  private let mainLabel = UILabel().then {
    $0.font = .h4
    $0.textColor = .black
    $0.textAlignment = .left
  }
  
  private let subLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = .init(name: "Pretendard-Regular", size: 14)
    $0.textAlignment = .left
    $0.sizeToFit()
    //        $0.isHidden = true
  }
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    _ = [mainLabel, subLabel].map { contentView.addSubview($0) }
    mainLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.right.equalToSuperview().inset(20)
      make.height.equalTo(24)
    }
    
    subLabel.snp.makeConstraints { make in
      make.top.equalTo(mainLabel.snp.bottom)
      make.left.right.equalTo(mainLabel)
    }
  }
  
  public func configureUI(with model: String) {
    mainLabel.text = "함께 하기 위한 질문"
    subLabel.text = "우리와 함께 하는 것에 대한 질문입니다. 상세하게 적어줄 수록 당신의 취미 레벨을 선정하기 쉬워집니다. "
  }
}
