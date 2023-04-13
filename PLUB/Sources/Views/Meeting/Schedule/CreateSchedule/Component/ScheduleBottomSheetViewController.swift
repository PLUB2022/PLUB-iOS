//
//  ScheduleBottomSheetViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/09.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

protocol ScheduleBottomSheetDelegate: AnyObject {
  func editSchedule(calendarID: Int)
  func deleteSchedule(calendarID: Int)
}

final class ScheduleBottomSheetViewController: BottomSheetViewController {
  weak var delegate: ScheduleBottomSheetDelegate?
  private let calendarID: Int
  
  private let lineView = UIView().then {
    $0.backgroundColor = .mediumGray
    $0.layer.cornerRadius = 2
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
    $0.backgroundColor = .background
  }
  
  private let editView = PhotoBottomSheetListView(
    text: "수정",
    image: "editBlack"
  )
  
  private let deleteView = PhotoBottomSheetListView(
    text: "삭제",
    image: "trashRed24",
    textColor: .error
  )
  
  init(calendarID: Int) {
    self.calendarID = calendarID
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
    [lineView, contentStackView].forEach {
      contentView.addSubview($0)
    }
    
    [editView, deleteView].forEach {
      contentStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    lineView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(8)
      $0.height.equalTo(4.33)
      $0.width.equalTo(52)
      $0.centerX.equalToSuperview()
    }
    
    contentStackView.snp.makeConstraints {
      $0.top.equalTo(lineView.snp.bottom).offset(26)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(78)
    }
    
    editView.snp.makeConstraints {
      $0.height.equalTo(52)
    }
    
    deleteView.snp.makeConstraints {
      $0.height.equalTo(52)
    }
  }
  
  override func bind() {
    super.bind()
    editView.button.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.delegate?.editSchedule(calendarID: owner.calendarID)
        owner.dismiss(animated: false)
      }
      .disposed(by: disposeBag)
    
    deleteView.button.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.delegate?.deleteSchedule(calendarID: owner.calendarID)
        owner.dismiss(animated: false)
      }
      .disposed(by: disposeBag)
  }
}
