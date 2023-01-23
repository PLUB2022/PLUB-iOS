//
//  QuestionTableViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/22.
//

import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa

protocol QuestionTableViewCellDelegate: AnyObject {
  func updateHeightOfRow(_ cell: QuestionTableViewCell, _ textView: UITextView)
  func addQuestion()
  func removeQuestion(index: Int)
  func updateQuestion(index: Int, data: MeetingQuestionCellModel)
}

final class QuestionTableViewCell: UITableViewCell {
  struct Constants {
    static let placeHolder = "질문을 입력해주세요"
  }
  
  private let disposeBag = DisposeBag()
  
  weak var delegate: QuestionTableViewCellDelegate?
  static let identifier = "QuestionTableViewCell"
  var indexPathRow = 0
  
  let inputTextView = InputTextView(
    title: "질문",
    placeHolder: Constants.placeHolder
  )
  
  private let removeButton = UIButton().then {
    $0.setImage(UIImage(named: "trashGray"), for: .normal)
    $0.isHidden = true
  }
    
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayouts()
    setupConstraints()
    setupStyles()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  override func prepareForReuse() {
    super.prepareForReuse()
    inputTextView.textView.text = nil
  }
}

private extension QuestionTableViewCell {
  func setupLayouts() {
    [inputTextView, removeButton].forEach {
      contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    inputTextView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.bottom.equalToSuperview().inset(16)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    removeButton.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.trailing.equalToSuperview().inset(16)
      $0.size.equalTo(32)
    }
  }
  
  func setupStyles() {
    selectionStyle = .none
    accessoryType = .none
    backgroundColor = .background
    removeButton.isHidden = true
  }
  
  func bind() {
    inputTextView.textView.rx.text.orEmpty
      .distinctUntilChanged()
      .withUnretained(self)
      .subscribe(onNext: { owner, text in
        owner.delegate?.updateHeightOfRow(owner, owner.inputTextView.textView)
        let textUnfilled = text.isEmpty ||
        text == Constants.placeHolder
        owner.removeButton.isHidden = textUnfilled
        owner.delegate?.updateQuestion(
          index: owner.indexPathRow,
          data: MeetingQuestionCellModel(
            question: text,
            isFilled: !textUnfilled
          )
        )
      })
      .disposed(by: disposeBag)
    
    removeButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.delegate?.removeQuestion(index: owner.indexPathRow)
      })
      .disposed(by: disposeBag)
  }
}
