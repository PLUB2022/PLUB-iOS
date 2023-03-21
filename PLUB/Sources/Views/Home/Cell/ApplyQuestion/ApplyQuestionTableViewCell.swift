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
  func whatQuestionAnswer(_ answer: ApplyAnswer)
}

final class ApplyQuestionTableViewCell: UITableViewCell {
  
  struct Constants {
    static let placeHolder = "소개하는 내용을 적어주세요"
  }
  
  static let identifier = "ApplyQuestionTableViewCell"
  
  private let disposeBag = DisposeBag()
  private var id: Int?
  
  weak var delegate: ApplyQuestionTableViewCellDelegate?
  
  private let containerView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  private let questionTextView = InputTextView(title: "", placeHolder: Constants.placeHolder, options: [.textCount])
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
    
    questionTextView.textView.rx.didEndEditing
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        if owner.questionTextView.textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          owner.delegate?.updateHeightOfRow(owner, owner.questionTextView.textView)
        }
      })
      .disposed(by: disposeBag)
    
    questionTextView.rx.text.orEmpty
      .filter { $0 != Constants.placeHolder }
      .distinctUntilChanged()
      .skip(1)
      .withUnretained(self)
      .subscribe(onNext: { owner, text in
        owner.delegate?.updateHeightOfRow(owner, owner.questionTextView.textView)
        owner.delegate?.whichQuestionChangedIn(QuestionStatus(id: owner.id ?? 0, isFilled: !text.isEmpty))
        owner.delegate?.whatQuestionAnswer(ApplyAnswer(questionID: owner.id ?? 0, answer: text))
      })
      .disposed(by: disposeBag)

  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.backgroundColor = .background
    contentView.addSubview(containerView)
    
    containerView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    containerView.addSubview(questionTextView)
    questionTextView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
      $0.bottom.equalToSuperview().inset(16)
    }
  }
  
  func configureUI(with model: ApplyQuestionTableViewCellModel) {
    self.id = model.id
    questionTextView.setTitleText(text: model.question)
  }
}
