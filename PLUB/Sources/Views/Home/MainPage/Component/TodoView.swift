//
//  TodoView.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/10.
//

import UIKit

import RxSwift
import SnapKit
import Then

protocol TodoViewDelegate: AnyObject {
  func whichTodoContent(content: String)
  func whichTodoChecked(isChecked: Bool, todoID: Int)
  func tappedMoreButton(todoID: Int, isChecked: Bool, isProof: Bool, content: String)
}

struct TodoViewModel {
  let todoID: Int
  let date: String
  let isChecked: Bool
  let content: String
  let isAuthor: Bool
  let isProof: Bool
  
  init(todoID: Int, date: String, isChecked: Bool, content: String, isAuthor: Bool, isProof: Bool) {
    self.todoID = todoID
    self.date = date
    self.isChecked = isChecked
    self.content = content
    self.isAuthor = isAuthor
    self.isProof = isProof
  }
  
  init(response: CreateTodoResponse) {
    todoID = response.todoID
    date = response.date
    isChecked = response.isChecked
    content = response.content
    isAuthor = response.isAuthor
    isProof = response.isProof
  }
  
  init(response: CompleteProofTodolistResponse) {
    todoID = response.todoID
    date = response.date
    isChecked = response.isChecked
    content = response.content
    isAuthor = response.isAuthor
    isProof = response.isProof
  }
}

final class TodoView: UIView {
  
  weak var delegate: TodoViewDelegate?
  private let disposeBag = DisposeBag()
  private let type: TodoViewType
  private var model: TodoViewModel?
  
  private lazy var emptyCheckView = UIView().then {
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.cornerRadius = 3
    $0.layer.masksToBounds = true
  }
  
  private lazy var contentLabel = UILabel().then {
    $0.text = "투두리스트목록"
    $0.isUserInteractionEnabled = true
  }
  
  private lazy var checkBoxButton = CheckBoxButton(type: .none)
  
  private lazy var todoTextField = UITextField().then {
    $0.placeholder = "새로운 TO-DO 추가하기"
    $0.delegate = self
    $0.returnKeyType = .done
    $0.isUserInteractionEnabled = true
  }
  
  private lazy var moreButton = UIButton().then {
    $0.setImage(UIImage(named: "meatballMenuBlack"), for: .normal)
  }
  
  private lazy var bottomLineView = UIView().then {
    $0.backgroundColor = .lightGray
  }
  
  init(type: TodoViewType) {
    self.type = type
    super.init(frame: .zero)
    configureUI()
    bind()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    switch type {
    case .input:
      [emptyCheckView, todoTextField].forEach { addSubview($0) }
      todoTextField.addSubview(bottomLineView)
      
      emptyCheckView.snp.makeConstraints {
        $0.size.equalTo(18)
        $0.leading.directionalVerticalEdges.equalToSuperview().inset(7)
      }
      
      todoTextField.snp.makeConstraints {
        $0.leading.equalTo(emptyCheckView.snp.trailing).offset(7)
        $0.directionalVerticalEdges.trailing.equalToSuperview()
      }
      
      bottomLineView.snp.makeConstraints {
        $0.directionalHorizontalEdges.bottom.equalToSuperview()
        $0.height.equalTo(1)
      }
      
    case .todo:
      [checkBoxButton, contentLabel].forEach { addSubview($0) }
      [bottomLineView, moreButton].forEach { contentLabel.addSubview($0) }
      checkBoxButton.snp.makeConstraints {
        $0.size.equalTo(18)
        $0.leading.directionalVerticalEdges.equalToSuperview().inset(7)
      }
      
      contentLabel.snp.makeConstraints {
        $0.leading.equalTo(checkBoxButton.snp.trailing).offset(7)
        $0.directionalVerticalEdges.equalToSuperview()
        $0.trailing.equalToSuperview()
      }
      
      bottomLineView.snp.makeConstraints {
        $0.width.equalToSuperview()
        $0.height.equalTo(1)
        $0.bottom.equalToSuperview()
      }
      
      moreButton.snp.makeConstraints {
        $0.size.equalTo(32)
        $0.centerY.trailing.equalToSuperview()
      }
    }
  }
  
  func changedTextForEdit(content: String?) {
    guard let content = content else { return }
    todoTextField.text = content
  }
  
  func clearTextField() {
    todoTextField.text = nil
  }
  
  func becomeResponder() {
    todoTextField.becomeFirstResponder()
  }
  
  func configureUI(with model: TodoViewModel) {
    self.model = model
    contentLabel.text = model.content
    checkBoxButton.isChecked = model.isChecked || model.isProof
    contentLabel.attributedText = model.isChecked ? contentLabel.text?.strikeThrough() : NSAttributedString(string: contentLabel.text ?? "")
    
    // 해당 투두가 인증되었거나 작성자가 아니라면 -> 체크버튼 비활성화
    checkBoxButton.isEnabled = model.isProof || !model.isAuthor ? false : true
  }
  
  private func bind() {
    checkBoxButton.rx.isChecked
      .subscribe(with: self) { owner, isChecked in
        guard let todoID = owner.model?.todoID else { return }
        owner.contentLabel.attributedText = isChecked ? owner.contentLabel.text?.strikeThrough() : NSAttributedString(string: owner.contentLabel.text ?? "")
        
        owner.delegate?.whichTodoChecked(isChecked: isChecked, todoID: todoID)
      }
      .disposed(by: disposeBag)
    
    moreButton.rx.tap
      .subscribe(with: self) { owner, _ in
        guard let model = owner.model else { return }
        owner.delegate?.tappedMoreButton(todoID: model.todoID, isChecked: owner.checkBoxButton.isChecked, isProof: model.isProof, content: model.content)
      }
      .disposed(by: disposeBag)
  }
}

extension TodoView: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return false }
    delegate?.whichTodoContent(content: text)
    textField.resignFirstResponder()
    return true
  }
}
