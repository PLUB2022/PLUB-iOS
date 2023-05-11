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
    todoViewModel = response.todoList.map { TodoViewModel(isChecked: $0.isChecked, content: $0.content) }
  }
}

protocol AddTodoViewDelegate: AnyObject {
  func whichCreateTodoRequest(request: CreateTodoRequest)
}

final class AddTodoView: UIView {
  
  weak var delegate: AddTodoViewDelegate?
  private var date: Date?
  private(set) var completionHandler: ((Date) -> Void)?
  
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
    
    let todoView = TodoView(type: .input)
    todoContainerView.addArrangedSubview(todoView)
    
    let today = DateFormatterFactory.todolistDate.string(from: Date())
    dateLabel.text = "\(today) (오늘)"
  }
  
  func configureUI(with model: AddTodoViewModel) {
    todoContainerView
      .arrangedSubviews.dropFirst(2)
      .forEach { $0.removeFromSuperview() }
    
    let sortedModel = model.todoViewModel.sorted { $0.isChecked || $1.isChecked }
    sortedModel.forEach { model in
      let todoView = TodoView(type: .todo)
      todoView.delegate = self
      todoView.configureUI(with: .init(
        isChecked: model.isChecked,
        content: model.content)
      )
      todoContainerView.addArrangedSubview(todoView)
    }
  }
}

extension AddTodoView: TodoViewDelegate {
  func whichTodoContent(content: String) {
    guard let date = self.date else { return }
    let dateString = DateFormatterFactory.dateWithHypen.string(from: date)
    delegate?.whichCreateTodoRequest(request: .init(content: content, date: dateString))
  }
}
