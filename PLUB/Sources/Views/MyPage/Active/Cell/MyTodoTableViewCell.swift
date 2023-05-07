//
//  MyTodoTableViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/29.
//

import UIKit

import SnapKit
import Then

final class MyTodoTableViewCell: UITableViewCell {
  static let identifier = "MyTodoTableViewCell"
  
  private let pointImageView = UIImageView().then {
    $0.image = UIImage(named: "pointActived")
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .main
  }
  
  private let todoView = UIView().then {
    $0.backgroundColor = .subBackground
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.main.cgColor
    $0.layer.cornerRadius = 10
  }
  
  private let dateLabel = UILabel().then {
    $0.font = .subtitle
    $0.textColor = .main
    $0.text = "오늘"
  }
  
  private let likeButton = UIButton().then {
    $0.setImage(UIImage(named: "heartFilled"), for: .normal)
    $0.contentMode = .scaleAspectFill
  }
  
  private let likeLabel = UILabel().then {
    $0.textColor = .deepGray
    $0.font = .overLine
    $0.text = "3"
  }
  
  private let todoStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 4
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    todoStackView.subviews.forEach {
      $0.removeFromSuperview()
    }
  }
  
  private func setupLayouts() {
    [lineView, pointImageView, todoView].forEach {
      contentView.addSubview($0)
    }
    
    [dateLabel, likeButton, likeLabel, todoStackView].forEach {
      todoView.addSubview($0)
    }
  }
  
  private func setupConstraints() {
    lineView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.equalToSuperview().inset(25)
      $0.width.equalTo(2)
    }
    
    pointImageView.snp.makeConstraints {
      $0.centerX.equalTo(lineView.snp.centerX)
      $0.top.equalToSuperview()
      $0.size.equalTo(10)
    }
    
    todoView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalTo(lineView.snp.trailing).offset(14)
      $0.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(8)
    }
    
    dateLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(18)
      $0.top.equalToSuperview().inset(10)
      $0.height.equalTo(32)
    }
    
    likeButton.snp.makeConstraints {
      $0.size.equalTo(32)
      $0.trailing.equalTo(likeLabel.snp.leading)
      $0.centerY.equalTo(dateLabel.snp.centerY)
    }
    
    likeLabel.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(14)
      $0.centerY.equalTo(dateLabel.snp.centerY)
    }
    
    todoStackView.snp.makeConstraints {
      $0.top.equalTo(dateLabel.snp.bottom).offset(10)
      $0.bottom.equalToSuperview().inset(16)
      $0.leading.equalToSuperview().inset(18)
      $0.trailing.equalToSuperview().inset(14)
    }
  }
  
  private func setupStyles() {
    backgroundColor = .background
    selectionStyle = .none
  }
  
  func setupData(with todo: TodoContent) {
    let date = DateFormatterFactory
      .dateWithHypen
      .date(from: todo.date) ?? Date()
    
    let isPast = (Date().compare(date) == .orderedDescending) ? true : false
    
    setupLineAndPointView(isPast: isPast)
    setupTodoViewStyle(isPast: isPast)
    setupDateLabel(date: date, isPast: isPast)
    setupLikeButton(totalLikes: todo.totalLikes)
    
    for todoItem in todo.todoList {
      let todoListView = TodoListView(todo: todoItem)
      todoStackView.addArrangedSubview(todoListView)
    }
  }
  
  private func setupLineAndPointView(isPast: Bool) {
    lineView.backgroundColor = isPast ? UIColor(hex: 0xD9D9D9): .main
    let pointImage = isPast ? UIImage(named: "pointInactived") : UIImage(named: "pointActived")
    pointImageView.image = pointImage
  }
  
  private func setupTodoViewStyle(isPast: Bool) {
    todoView.backgroundColor = isPast ? .white : .subBackground
    todoView.layer.borderColor = isPast ? UIColor.white.cgColor : UIColor.main.cgColor
  }
  
  private func setupDateLabel(date: Date, isPast: Bool) {
    dateLabel.textColor = isPast ? .deepGray : .main
    
    let todoDateText =  Calendar.current.isDateInToday(date)
    ?  "오늘"
    : DateFormatterFactory
      .todolistDate.string(from: date)
    
    dateLabel.text = todoDateText
  }
  
  private func setupLikeButton(totalLikes: Int) {
    likeLabel.text = "\(totalLikes)"
    let buttonImage = totalLikes > 0 ? UIImage(named: "heartFilled") : UIImage(named: "heart")
    likeButton.setImage(buttonImage, for: .normal)
  }
}
