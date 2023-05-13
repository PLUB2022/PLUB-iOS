//
//  AddTodolistBottomSheetViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/12.
//

import UIKit

import RxSwift
import SnapKit
import Then

enum AddTodolistBottomSheetType {
  case complete
  case noComplete
}

protocol AddTodolistBottomSheetDelegate: AnyObject {
  func proofImage(todoID: Int)
  func editTodo(todoID: Int)
  func deleteTodo(todoID: Int)
}

final class AddTodolistBottomSheetViewController: BottomSheetViewController {
  
  weak var delegate: AddTodolistBottomSheetDelegate?
  
  private let type: AddTodolistBottomSheetType
  private let todoID: Int
  
  private let stackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private lazy var proofImageListView = BottomSheetListView(text: "사진 인증", image: "editBlack")
  private let editTodoListView = BottomSheetListView(text: "TO-DO 수정", image: "editBlack")
  private let deleteTodoListView = BottomSheetListView(text: "TO-DO 삭제", image: "trashRed", textColor: .error)
  
  init(type: AddTodolistBottomSheetType, todoID: Int) {
    self.type = type
    self.todoID = todoID
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    
    proofImageListView.button.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.proofImage(todoID: owner.todoID)
      }
      .disposed(by: disposeBag)
    
    editTodoListView.button.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.editTodo(todoID: owner.todoID)
      }
      .disposed(by: disposeBag)
    
    deleteTodoListView.button.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.deleteTodo(todoID: owner.todoID)
      }
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    contentView.addSubview(stackView)
    
    switch type {
    case .complete:
      [proofImageListView, editTodoListView, deleteTodoListView].forEach { stackView.addArrangedSubview($0) }
    case .noComplete:
      [editTodoListView, deleteTodoListView].forEach { stackView.addArrangedSubview($0) }
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    stackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Metrics.Margin.top)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Metrics.Margin.horizontal)
      $0.bottom.equalToSuperview().inset(Metrics.Margin.bottom)
    }
    
    switch type {
    case .complete:
      [proofImageListView, editTodoListView, deleteTodoListView].forEach {
        $0.snp.makeConstraints {
          $0.height.equalTo(Metrics.Size.listHeight)
        }
      }
    case .noComplete:
      [editTodoListView, deleteTodoListView].forEach {
        $0.snp.makeConstraints {
          $0.height.equalTo(Metrics.Size.listHeight)
        }
      }
    }
  }
}
