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

struct TodoViewModel {
  let isChecked: Bool
  let content: String
}

struct AddTodoViewModel {
  let todoViewModel: [TodoViewModel]
}

final class AddTodoView: UIView {
  
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
      let dateString = DateFormatterFactory.todolistDate.string(from: date)
      if Calendar.current.isDateInToday(date) {
        self?.dateLabel.text = "\(dateString) (오늘)"
      } else {
        self?.dateLabel.text = dateString
      }
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
    model.todoViewModel.forEach { model in
      let todoView = TodoView(type: .todo)
      todoView.configureUI(with: .init(
        isChecked: model.isChecked,
        content: model.content)
      )
      todoContainerView.addArrangedSubview(todoView)
    }
  }
}

extension AddTodoView {
  final class TodoView: UIView {
    
    private let disposeBag = DisposeBag()
    private let type: TodoViewType
    
    private lazy var emptyCheckView = UIView().then {
      $0.layer.borderWidth = 1
      $0.layer.borderColor = UIColor.lightGray.cgColor
      $0.layer.cornerRadius = 3
      $0.layer.masksToBounds = true
    }
    
    private lazy var contentLabel = UILabel().then {
      $0.text = "투두리스트목록"
    }
    
    private lazy var checkBoxButton = CheckBoxButton(type: .none)
    
    private let todoTextField = UITextField().then {
      $0.placeholder = "새로운 TO-DO 추가하기"
      $0.layer.shouldRasterize = true
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
        contentLabel.addSubview(bottomLineView)
        contentLabel.addSubview(moreButton)
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
          $0.directionalVerticalEdges.trailing.equalToSuperview()
        }
      }
    }
    
    func configureUI(with model: TodoViewModel) {
      contentLabel.text = model.content
      checkBoxButton.isChecked = model.isChecked
      contentLabel.attributedText = model.isChecked ? contentLabel.text?.strikeThrough() : NSAttributedString(string: contentLabel.text ?? "")
    }
    
    private func bind() {
      checkBoxButton.rx.isChecked
        .subscribe(with: self) { owner, isChecked in
          owner.contentLabel.attributedText = isChecked ? owner.contentLabel.text?.strikeThrough() : NSAttributedString(string: owner.contentLabel.text ?? "")
        }
        .disposed(by: disposeBag)
    }
  }
}
