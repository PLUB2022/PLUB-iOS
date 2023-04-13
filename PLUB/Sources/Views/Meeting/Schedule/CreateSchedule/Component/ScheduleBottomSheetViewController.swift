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
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
    $0.backgroundColor = .background
  }
  
  private let editView = BottomSheetListView(
    text: "수정",
    image: "editBlack"
  )
  
  private let deleteView = BottomSheetListView(
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
  
  override func setupLayouts() {
    super.setupLayouts()
    contentView.addSubview(contentStackView)
    
    [editView, deleteView].forEach {
      contentStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    contentStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(36)
      $0.directionalHorizontalEdges.bottom.equalToSuperview().inset(24)
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
        owner.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
    
    deleteView.button.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.delegate?.deleteSchedule(calendarID: owner.calendarID)
        owner.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
  }
}
