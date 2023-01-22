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
}

final class QuestionTableViewCell: UITableViewCell {
  private let disposeBag = DisposeBag()
  
  weak var delegate: QuestionTableViewCellDelegate?
  static let identifier = "QuestionTableViewCell"
  var indexPathRow = 0
  
  private let inputTextView = InputTextView(
    title: "질문",
    placeHolder: "질문을 입력해주세요"
  )
    
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
    contentView.addSubview(inputTextView)
  }
  
  func setupConstraints() {
    inputTextView.snp.makeConstraints {
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
  
  func bind() {
    inputTextView.textView.rx.text.orEmpty
      .distinctUntilChanged()
      .skip(1)
      .withUnretained(self)
      .subscribe(onNext: { owner, text in
        owner.delegate?.updateHeightOfRow(owner, owner.inputTextView.textView)
      })
      .disposed(by: disposeBag)
  }
}
