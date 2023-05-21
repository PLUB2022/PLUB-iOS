//
//  AddTodoView.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/08.
//

import UIKit

import RxSwift
import SnapKit
import Then

enum TodoViewType {
  case input // 투두입력할 수 있는 타입
  case todo // 입력한 투두에 대한 타입
}

struct AddTodoViewModel {
  let todoViewModel: [TodoViewModel]
  
  init(response: InquireTodolistByDateResponse) {
    todoViewModel = response.todoList.map {
      TodoViewModel(
        todoID: $0.todoID,
        date: $0.date,
        isChecked: $0.isChecked,
        content: $0.content,
        isAuthor: $0.isAuthor,
        isProof: $0.isProof
      )
    }
  }
  
  init(todoViewModel: [TodoViewModel]) {
    self.todoViewModel = todoViewModel
  }
}

protocol AddTodoViewDelegate: AnyObject {
  func whichCreateTodoRequest(request: CreateTodoRequest, type: AddTodoType)
  func whichTodoChecked(isChecked: Bool, todoID: Int)
  func tappedMoreButton(todoID: Int, isChecked: Bool, isProof: Bool, content: String)
}

enum AddTodoType {
  case create
  case edit
}

final class AddTodoView: UIView {
  
  weak var delegate: AddTodoViewDelegate?
  private var type: AddTodoType = .create 
  private var date: Date?
  private(set) var completionHandler: ((Date) -> Void)?
  private(set) var todoHandler: ((AddTodoType, String?) -> Void)?
  
  private let todoContainerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
    $0.spacing = 10
  }
  
  private let dateLabel = UILabel().then {
    $0.textColor = .main
    $0.font = .h5
  }
  
  private lazy var inputTodoView = TodoView(type: .input).then {
    $0.delegate = self
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    completionHandler = { [weak self] date in
      self?.date = date
      let dateString = DateFormatterFactory.todolistDate.string(from: date)
      let isToday = Calendar.current.isDateInToday(date)
      self?.dateLabel.text = isToday ? "\(dateString) (오늘)" : dateString
      self?.dateLabel.textColor = isToday ? .main : .black
    }
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(todoContainerView)
    
    todoContainerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
    
    todoContainerView.addArrangedSubview(dateLabel)
    todoContainerView.addArrangedSubview(inputTodoView)
    
    let today = DateFormatterFactory.todolistDate.string(from: Date())
    dateLabel.text = "\(today) (오늘)"
  }
  
  func configureUI(with model: AddTodoViewModel) {
    todoContainerView
      .arrangedSubviews[2...]
      .forEach { $0.removeFromSuperview() }
    
    todoHandler = { [weak self] type, content in
      guard let self = self else { return }
      self.type = type
      self.inputTodoView.changedTextForEdit(content: content)
      self.inputTodoView.becomeResponder()
    }
    
    model.todoViewModel.forEach { model in
      let todoView = TodoView(type: .todo)
      todoView.delegate = self
      todoView.configureUI(with: .init(
        todoID: model.todoID,
        date: model.date,
        isChecked: model.isChecked,
        content: model.content,
        isAuthor: model.isAuthor,
        isProof: model.isProof)
      )
      todoContainerView.addArrangedSubview(todoView)
    }
  }
}

extension AddTodoView: TodoViewDelegate {
  func inputTextIsEmpty(isEmpty: Bool) {
    if type == .edit && isEmpty {
      type = .create
    }
  }
  
  func tappedMoreButton(todoID: Int, isChecked: Bool, isProof: Bool, content: String) {
    delegate?.tappedMoreButton(todoID: todoID, isChecked: isChecked, isProof: isProof, content: content)
  }
  
  func whichTodoChecked(isChecked: Bool, todoID: Int) {
    delegate?.whichTodoChecked(isChecked: isChecked, todoID: todoID)
  }
  
  func whichTodoContent(content: String) {
    guard let date = self.date else { return }
    let dateString = DateFormatterFactory.dateWithHypen.string(from: date)
    delegate?.whichCreateTodoRequest(request: .init(content: content, date: dateString), type: type)
    inputTodoView.clearTextField()
  }
}
