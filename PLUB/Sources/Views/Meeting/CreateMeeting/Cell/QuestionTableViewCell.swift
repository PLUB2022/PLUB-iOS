//
//  QuestionTableViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/22.
//

import UIKit

import SnapKit
import Then

final class QuestionTableViewCell: UITableViewCell {
    
  static let identifier = "QuestionTableViewCell"
  
  private let textView = InputTextView(
    title: "질문",
    placeHolder: "질문을 입력해주세요"
  )
    
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  override func prepareForReuse() {
    super.prepareForReuse()
    textView.textView.text = nil
  }
}

private extension QuestionTableViewCell {
  func setupLayouts() {
    contentView.addSubview(textView)
  }
  
  func setupConstraints() {
    textView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.bottom.equalToSuperview().inset(16)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
  }
  
  func setupStyles() {
    selectionStyle = .none
    accessoryType = .none
    backgroundColor = .background
  }
}
