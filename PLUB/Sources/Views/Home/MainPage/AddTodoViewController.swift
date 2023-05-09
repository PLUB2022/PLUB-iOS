//
//  AddTodoViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/29.
//

import UIKit

import FSCalendar
import SnapKit
import Then

final class AddTodoViewController: BaseViewController {
  
  private let scrollView = UIScrollView()
  
  private let containerStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 16
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: 16, bottom: .zero, right: 16)
  }
  
  private let textLabel = UILabel().then {
    $0.text = "새 To-Do 추가하기"
  }
  
  private lazy var calendarView = FSCalendar().then {
    $0.delegate = self
    $0.dataSource = self
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.appearance.headerTitleColor = UIColor.black
    $0.appearance.todayColor = .white
    $0.appearance.weekdayTextColor = .gray
    $0.appearance.titleWeekendColor = .red
  }
  
  private let addTodoView = AddTodoView().then {
    $0.backgroundColor = .subMain
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.main.cgColor
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerStackView)
    [textLabel, calendarView, addTodoView].forEach { containerStackView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    containerStackView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.width.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    textLabel.snp.makeConstraints {
      $0.height.equalTo(29)
    }
    
    calendarView.snp.makeConstraints {
      $0.height.equalTo(357.29)
    }
    
    containerStackView.setCustomSpacing(13.71, after: calendarView)
  }
}

extension AddTodoViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
      return .main
  }
  
  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
    if Calendar.current.isDateInToday(date) {
      return .white
    }
      return nil
  }
  
  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    if Calendar.current.isDateInToday(date) {
      addTodoView.layer.borderColor = UIColor.main.cgColor
      addTodoView.backgroundColor = .subMain
    } else {
      addTodoView.layer.borderColor = UIColor.lightGray.cgColor
      addTodoView.backgroundColor = .white
    }
  }
  func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
    if Calendar.current.isDateInToday(date) {
      return "오늘"
    }
    return nil
  }
  
  func calendar(_ calendar: FSCalendar, borderDefaultColorForDate date: Date) -> UIColor? {
    if Calendar.current.isDateInToday(date) {
      return .main
    }
    return nil
  }
  
}
