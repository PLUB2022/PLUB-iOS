//
//  QuestionDeleteBottomSheetViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/28.
//

import UIKit

protocol QuestionDeleteBottomSheetDelegate: AnyObject {
  func removeQuestion(index: Int, lastQuestion: Bool)
}

final class QuestionDeleteBottomSheetViewController: BottomSheetViewController {
  weak var delegate: QuestionDeleteBottomSheetDelegate?
  
  private var questionIndex: Int
  private var lastQuestion: Bool
  
  private let lineView = UIView().then {
    $0.backgroundColor = .mediumGray
    $0.layer.cornerRadius = 2
  }
  
  private lazy var titleLabel = UILabel().then {
    $0.attributedText = setTitleAttributeText(
      count: questionIndex,
      lastQuestion: lastQuestion
    )
    $0.numberOfLines = 0
    $0.font = .subtitle
    $0.textAlignment = .left
  }
  
  private let buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 16
    $0.distribution = .fillEqually
  }
  
  private let backButton = UIButton().then {
    $0.setTitle("아니요! 그냥 둘게요.", for: .normal)
    $0.setTitleColor(.deepGray, for: .normal)
    $0.titleLabel?.font = .button
    $0.layer.cornerRadius = 10
    $0.backgroundColor = .lightGray
  }
  
  private let deleteButton = UIButton().then {
    $0.setTitle("네, 삭제할게요.", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.titleLabel?.font = .button
    $0.layer.cornerRadius = 10
    $0.backgroundColor = .error
  }
  
  init(
    index: Int,
    lastQuestion: Bool
  ) {
    questionIndex = index
    self.lastQuestion = lastQuestion
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [lineView, titleLabel, buttonStackView].forEach {
      contentView.addSubview($0)
    }
    
    [backButton, deleteButton].forEach {
      buttonStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    contentView.snp.remakeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(206)
    }
    
    lineView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(8)
      $0.height.equalTo(4)
      $0.width.equalTo(48)
      $0.centerX.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(lineView.snp.bottom).offset(31)
      $0.height.greaterThanOrEqualTo(19)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    buttonStackView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(15)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.height.equalTo(48)
    }
  }
  
  override func bind() {
    super.bind()
    backButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.dismiss(animated: false)
      })
      .disposed(by: disposeBag)
    
    deleteButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.delegate?.removeQuestion(index: owner.questionIndex, lastQuestion: owner.lastQuestion)
        owner.dismiss(animated: false)
      })
      .disposed(by: disposeBag)
  }
  
  private func setTitleAttributeText(count: Int, lastQuestion: Bool) -> NSMutableAttributedString {
    let purpleCharacters = NSAttributedString(
      string: "질문 \(count + 1)",
      attributes: [.foregroundColor: UIColor.main]
    )
    
    let blackCharacters = NSAttributedString(
      string: "를 삭제 할까요?" + (lastQuestion ? "\n삭제할 경우 질문 없이 모집하기로 변경돼요." : ""),
      attributes: [.foregroundColor: UIColor.black]
    )

    return NSMutableAttributedString(attributedString: purpleCharacters).then {
      $0.append(blackCharacters)
    }
  }
}
