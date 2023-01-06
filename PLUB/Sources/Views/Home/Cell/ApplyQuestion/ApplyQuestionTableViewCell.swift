//
//  ApplyQuestionTableViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/04.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

struct ApplyQuestionTableViewCellModel {
  let question: String
  let placeHolder: String
}

protocol ApplyQuestionTableViewCellDelegate: AnyObject {
  func updateHeightOfRow(_ cell: ApplyQuestionTableViewCell, _ textView: UITextView)
}

class ApplyQuestionTableViewCell: UITableViewCell {
  
  static let identifier = "ApplyQuestionTableViewCell"
  
  private var disposeBag = DisposeBag()
  
  public weak var delegate: ApplyQuestionTableViewCellDelegate?
  
  private let containerView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  private let questionLabel = UILabel().then {
    $0.font = .body1
    $0.textColor = .black
  }
  
  private let questionTextView = UITextView().then {
    $0.textColor = .deepGray
    $0.backgroundColor = .white
    $0.font = UIFont(name: "Pretendard-Regular", size: 14)
    $0.layer.cornerRadius = 8
    $0.layer.masksToBounds = true
    $0.isScrollEnabled = false
  }
  
  private let countLabel = UILabel().then {
    $0.textColor = .mediumGray
    $0.font = .systemFont(ofSize: 12)
    $0.text = "0"
    $0.sizeToFit()
  }
  
  private let maxCountLabel = UILabel().then {
    $0.textColor = .deepGray
    $0.font = .systemFont(ofSize: 12)
    $0.text = "/100"
    $0.sizeToFit()
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
    
    questionTextView.rx.didBeginEditing.withUnretained(self).subscribe(onNext: { owner, _ in
      if owner.questionTextView.text == "소개하는 내용을 적어주세요" {
        owner.questionTextView.text = nil
        owner.questionTextView.textColor = .black
      }
    })
    .disposed(by: disposeBag)
    
    questionTextView.rx.didEndEditing.withUnretained(self).subscribe(onNext: { owner, _ in
      if owner.questionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        owner.questionTextView.textColor = .deepGray
        owner.questionTextView.text = "소개하는 내용을 적어주세요"
      }
    })
    .disposed(by: disposeBag)
    
    questionTextView.rx.text.orEmpty.withUnretained(self)
      .subscribe(onNext: { owner, text in
        guard text != "소개하는 내용을 적어주세요" else { return }
        owner.countLabel.text = "\(text.count)"
        owner.delegate?.updateHeightOfRow(owner, owner.questionTextView)
      })
      .disposed(by: disposeBag)
    
    questionTextView.rx.setDelegate(self).disposed(by: disposeBag)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.backgroundColor = .secondarySystemBackground
    contentView.addSubview(containerView)
    _ = [questionLabel, questionTextView, countLabel, maxCountLabel].map { containerView.addSubview($0) }
    
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    questionLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.right.equalToSuperview().inset(20)
      make.height.equalTo(19)
    }
    
    questionTextView.snp.makeConstraints { make in
      make.top.equalTo(questionLabel.snp.bottom)
      make.left.right.equalTo(questionLabel)
      make.bottom.equalTo(containerView).offset(-50)
    }
    
    maxCountLabel.snp.makeConstraints { make in
      make.right.equalTo(questionTextView)
      make.top.equalTo(questionTextView.snp.bottom)
    }
    
    countLabel.snp.makeConstraints { make in
      make.centerY.equalTo(maxCountLabel)
      make.right.equalTo(maxCountLabel.snp.left)
    }
  }
  
  public func configureUI(with model: ApplyQuestionTableViewCellModel) {
    questionLabel.text = model.question
    questionTextView.text = model.placeHolder
  }
}

extension ApplyQuestionTableViewCell: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
    let numberOfChars = newText.count
    
    if(numberOfChars > 100){
      return false
    }
    return true
  }
}
