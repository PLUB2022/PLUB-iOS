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
    view.addSubview(containerStackView)
    [textLabel, calendarView, addTodoView].forEach { containerStackView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.directionalHorizontalEdges.equalToSuperview()
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
  
}
