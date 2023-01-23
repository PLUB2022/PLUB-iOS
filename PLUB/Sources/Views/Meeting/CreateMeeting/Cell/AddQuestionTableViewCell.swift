//
//  AddQuestionTableViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/23.
//

import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa

final class AddQuestionTableViewCell: UITableViewCell {
  private let disposeBag = DisposeBag()
  
  weak var delegate: QuestionTableViewCellDelegate?
  static let identifier = "AddQuestionTableViewCell"
    
  let addQuestionControl = AddQuestionControl()
  
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
  }
}

private extension AddQuestionTableViewCell {
  func setupLayouts() {
    contentView.addSubview(addQuestionControl)
  }
  
  func setupConstraints() {
    addQuestionControl.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.height.equalTo(36)
      $0.width.equalTo(105)
      $0.top.bottom.equalToSuperview()
    }
  }
  
  func setupStyles() {
    selectionStyle = .none
    accessoryType = .none
    backgroundColor = .background
  }
  
  func bind() {
    addQuestionControl.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.delegate?.addQuestion()
      })
      .disposed(by: disposeBag)
  }
}
