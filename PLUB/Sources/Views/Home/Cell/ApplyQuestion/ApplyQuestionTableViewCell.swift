//
//  ApplyQuestionTableViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/04.
//

import UIKit
import SnapKit
import Then

struct ApplyQuestionTableViewCellModel {
  let question: String
  let placeHolder: String
}

protocol ApplyQuestionTableViewCellDelegate: AnyObject {
    func updateHeightOfRow(_ cell: ApplyQuestionTableViewCell, _ textView: UITextView)
}

class ApplyQuestionTableViewCell: UITableViewCell {
  
  static let identifier = "ApplyQuestionTableViewCell"
  
  public weak var delegate: ApplyQuestionTableViewCellDelegate?
  
  private let questionLabel = UILabel().then {
    $0.font = .body1
    $0.textColor = .black
  }
  
  private let questionTextView = UITextView().then {
    $0.text = "잠시만요"
    $0.textColor = .deepGray
    $0.backgroundColor = .white
    $0.font = UIFont(name: "Pretendard-Regular", size: 14)
    $0.layer.cornerRadius = 8
    $0.layer.masksToBounds = true
    $0.isScrollEnabled = false
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.backgroundColor = .secondarySystemBackground
    questionTextView.delegate = self
    _ = [questionLabel, questionTextView].map { contentView.addSubview($0) }
    
    questionLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.right.equalToSuperview().inset(20)
      make.height.equalTo(19)
    }
    
    questionTextView.snp.makeConstraints { make in
      make.top.equalTo(questionLabel.snp.bottom)
      make.left.right.equalTo(questionLabel)
      make.bottom.equalToSuperview()
      //          make.height.equalTo(100)
    }
  }
  
  public func configureUI(with model: ApplyQuestionTableViewCellModel) {
    questionLabel.text = model.question
    questionTextView.text = model.placeHolder
  }
}

extension ApplyQuestionTableViewCell: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == "소개하는 내용을 입력해주세요" {
      textView.text = nil
      textView.textColor = .black
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      textView.textColor = .deepGray
      textView.text = "소개하는 내용을 입력해주세요"
    }
  }
  
  func textViewDidChange(_ textView: UITextView) {
      delegate?.updateHeightOfRow(self, textView)
  }
}
