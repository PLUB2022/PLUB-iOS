//
//  DateBottomSheetViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/18.
//

import UIKit

protocol DateBottomSheetDelegate: AnyObject {
  func selectDate(date: String)
}

final class DateBottomSheetViewController: BottomSheetViewController {
  weak var delegate: DateBottomSheetDelegate?
  
  private let lineView = UIView().then {
    $0.backgroundColor = .mediumGray
    $0.layer.cornerRadius = 2
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 24
    $0.backgroundColor = .background
  }
  
  private let datePicker = UIDatePicker().then {
    $0.preferredDatePickerStyle = .wheels
    $0.datePickerMode = .time
  }
  
  private var nextButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "생일 입력 완료")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [lineView, contentStackView].forEach {
      contentView.addSubview($0)
    }
    
    [datePicker, nextButton].forEach {
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
      $0.bottom.equalToSuperview().inset(38)
    }
    
    datePicker.snp.makeConstraints {
      $0.height.equalTo(178)
    }
    
    nextButton.snp.makeConstraints {
      $0.height.equalTo(48)
    }
  }
  
  override func bind() {
    super.bind()
    nextButton.rx.tap
      .withUnretained(self)
      .asDriver(onErrorDriveWith: .empty())
      .drive(onNext: { _ in
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "HH:mm"
        let date = formatter.string(from: self.datePicker.date)
        self.delegate?.selectDate(date: date)
        self.dismiss(animated: false)
      })
      .disposed(by: disposeBag)
  }
}
