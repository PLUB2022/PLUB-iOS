//
//  DateBottomSheetViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/18.
//

import UIKit

protocol DateBottomSheetDelegate: AnyObject {
  func selectDate(date: Date)
}

final class DateBottomSheetViewController: BottomSheetViewController {
  
  weak var delegate: DateBottomSheetDelegate?
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 24
    $0.backgroundColor = .background
  }
  
  private let datePicker = UIDatePicker().then {
    $0.preferredDatePickerStyle = .wheels
    $0.locale = Locale(identifier: "ko-KR")
  }
  
  private let nextButton = UIButton(configuration: .plain())
  
  init(
    type: UIDatePicker.Mode,
    buttonTitle: String
  ) {
    datePicker.datePickerMode = type
    nextButton.configurationUpdateHandler = nextButton.configuration?.plubButton(label: buttonTitle)
    super.init(nibName: nil, bundle: nil)
  }
  
  convenience init(maximumDate: Date, buttonTitle: String) {
    self.init(type: .date, buttonTitle: buttonTitle)
    datePicker.maximumDate = maximumDate
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    contentView.addSubview(contentStackView)
    
    [datePicker, nextButton].forEach {
      contentStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    
    contentStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(36)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(4)
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
      .drive(onNext: { owner, _ in
        owner.delegate?.selectDate(date: owner.datePicker.date)
        owner.dismiss(animated: false)
      })
      .disposed(by: disposeBag)
  }
}
