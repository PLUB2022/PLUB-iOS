//
//  RecruitingTableViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/17.
//

import UIKit

import SnapKit
import Then

final class RecruitingTableViewCell: UITableViewCell {
  static let identifier = "RecruitingTableViewCell"
  
  private let containerView = UIView().then {
    $0.backgroundColor = .white
  }
  
  private let questionLabel = UILabel().then {
    $0.font = .body2
    $0.textColor = .mediumGray
  }
  
  private let answerLabel = UILabel().then {
    $0.font = .body1
    $0.numberOfLines = 0
    $0.textColor = .black
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    addSubview(containerView)
    [questionLabel, answerLabel].forEach {
      containerView.addSubview($0)
    }
  }
  
  private func setupConstraints() {
    containerView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.top.bottom.equalToSuperview()
    }
    
    questionLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(8)
      $0.leading.trailing.equalToSuperview().inset(20)
    }
    
    answerLabel.snp.makeConstraints {
      $0.top.equalTo(questionLabel.snp.bottom).offset(6)
      $0.leading.equalToSuperview().inset(30)
      $0.trailing.equalToSuperview().inset(20)
      $0.bottom.equalToSuperview().inset(8)
    }
  }
  
  private func setupStyles() {
    backgroundColor = .background
    selectionStyle = .none
  }
  
  func setupData(with data: Answer) {
    questionLabel.text = data.question
    answerLabel.text = data.answer
  }
}
