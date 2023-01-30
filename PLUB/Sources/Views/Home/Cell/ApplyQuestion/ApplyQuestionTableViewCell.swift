//
//  ApplyQuestionTableViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/04.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

struct ApplyQuestionTableViewCellModel {
  let id: Int
  let question: String
}

protocol ApplyQuestionTableViewCellDelegate: AnyObject {
  func updateHeightOfRow(_ cell: ApplyQuestionTableViewCell, _ textView: UITextView)
  func whichQuestionChangedIn(_ status: QuestionStatus)
}

class ApplyQuestionTableViewCell: UITableViewCell {
  
  struct Constants {
    static let placeHolder = "소개하는 내용을 적어주세요"
  }
  
  static let identifier = "ApplyQuestionTableViewCell"
  
  private var disposeBag = DisposeBag()
  private var id: Int?
  
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
    $0.font = .body2
    $0.layer.cornerRadius = 8
    $0.layer.masksToBounds = true
    $0.isScrollEnabled = false
  }
  
  private let countLabel = UILabel().then {
    $0.textColor = .mediumGray
    $0.font = .overLine
    $0.text = "0"
    $0.sizeToFit()
  }
  
  private let maxCountLabel = UILabel().then {
    $0.textColor = .deepGray
    $0.font = .overLine
    $0.text = "/300"
    $0.sizeToFit()
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
    
    questionTextView.rx.didBeginEditing
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        if owner.questionTextView.text == Constants.placeHolder {
          owner.questionTextView.text = nil
          owner.questionTextView.textColor = .black
        }
      })
      .disposed(by: disposeBag)
    
    questionTextView.rx.didEndEditing
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        if owner.questionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          owner.questionTextView.textColor = .deepGray
          owner.questionTextView.text = Constants.placeHolder
          owner.delegate?.updateHeightOfRow(owner, owner.questionTextView)
        }
      })
      .disposed(by: disposeBag)
    
    questionTextView.rx.text.orEmpty
      .filter { $0 != Constants.placeHolder }
      .distinctUntilChanged()
      .skip(1)
      .do(onNext: { print("text = \($0)") })
      .withUnretained(self)
      .subscribe(onNext: { owner, text in
        owner.countLabel.text = "\(text.count)"
        owner.delegate?.updateHeightOfRow(owner, owner.questionTextView)
        owner.delegate?.whichQuestionChangedIn(QuestionStatus(id: owner.id ?? 0, isFilled: !text.isEmpty))
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
    [questionLabel, questionTextView, countLabel, maxCountLabel].forEach { containerView.addSubview($0) }
    
    containerView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    questionLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.right.equalToSuperview().inset(20)
      $0.height.equalTo(19)
    }
    
    questionTextView.snp.makeConstraints {
      $0.top.equalTo(questionLabel.snp.bottom)
      $0.left.right.equalTo(questionLabel)
      $0.bottom.equalTo(containerView).offset(-50)
    }
    
    maxCountLabel.snp.makeConstraints {
      $0.right.equalTo(questionTextView)
      $0.top.equalTo(questionTextView.snp.bottom)
    }
    
    countLabel.snp.makeConstraints {
      $0.centerY.equalTo(maxCountLabel)
      $0.right.equalTo(maxCountLabel.snp.left)
    }
  }
  
  public func configureUI(with model: ApplyQuestionTableViewCellModel) {
    questionLabel.text = model.question
    questionTextView.text = Constants.placeHolder
    self.id = model.id
  }
}

extension ApplyQuestionTableViewCell: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
    let numberOfChars = newText.count
    
    if(numberOfChars > 300){
      return false
    }
    return true
  }
}
