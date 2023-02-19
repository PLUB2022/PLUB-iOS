//
//  MeetingScheduleViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/18.
//

import UIKit

enum MeetingScheduleType: String, CaseIterable {
  case date = "날짜/시간"
  case location = "장소"
  case alarm = "알림"
  case memo = "메모"
  
  var imageName: String {
    switch self {
    case .date:
      return "calendarBlack"
    case .location:
      return "locationBlack"
    case .alarm:
      return "bellBlack"
    case .memo:
      return "memoBlack"
    }
  }
}

final class MeetingScheduleViewController: BaseViewController {
  private let viewModel = MeetingScheduleViewModel()
  
  private let scrollView = UIScrollView().then {
    $0.bounces = false
    $0.showsVerticalScrollIndicator = false
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 33
  }
  
  private let titleTextField = PaddingTextField().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 12.5
    $0.attributedPlaceholder = NSAttributedString(
      string: "일정 제목을 입력해 주세요.",
      attributes: [
        .foregroundColor : UIColor.mediumGray,
        .font: UIFont.h5!
      ]
    )
    $0.textColor = .black
    $0.font = .h5
    
    $0.leftView = UIView()
    $0.rightView = UIView()
    $0.leftViewMode = .always
    $0.rightViewMode = .always
    $0.leftViewPadding = 12
    $0.rightViewPadding = 12
  }
  
  private let allDaySwitch = UISwitch().then {
    $0.onTintColor = .main
  }
  
  private let startDatePicker = UIDatePicker().then {
    $0.preferredDatePickerStyle = .compact
    $0.datePickerMode = .dateAndTime
    $0.locale = Locale(identifier: "ko-KR")
    $0.tintColor = .main
  }
  
  private let endDatePicker = UIDatePicker().then {
    $0.preferredDatePickerStyle = .compact
    $0.datePickerMode = .dateAndTime
    $0.locale = Locale(identifier: "ko-KR")
    $0.tintColor = .main
  }
  
  private let locationTextField = PaddingTextField().then {
    $0.leftView = UIView()
    $0.rightView = UIView()
    $0.leftViewMode = .always
    $0.rightViewMode = .always
    $0.leftViewPadding = 12.5
    $0.rightViewPadding = 12.5
    $0.attributedPlaceholder = NSAttributedString(
      string: "장소를 입력해 주세요",
      attributes: [
        .foregroundColor : UIColor.mediumGray,
        .font: UIFont.appFont(family: .pretendard(option: .regular), size: 14)
      ]
    )
    $0.textColor = .black
    $0.font = UIFont.body2
  }
  
  private let memoTextView = UITextView().then {
    $0.textContainerInset.left = 12.5
    $0.textContainerInset.right = 12.5
//    $0.attributedPlaceholder = NSAttributedString(
//      string: "장소를 입력해 주세요",
//      attributes: [
//        .foregroundColor : UIColor.mediumGray,
//        .font: UIFont.appFont(family: .pretendard(option: .regular), size: 14)
//      ]
//    )
    $0.isScrollEnabled = false
    $0.textColor = .black
    $0.font = UIFont.body2
    $0.backgroundColor = .clear
  }
  
  private let scheduleAlarmView = ScheduleAlarmView()
  
  private let registerButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "일정 등록")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerKeyboardNotification()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeKeyboardNotification()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [scrollView, registerButton].forEach {
      view.addSubview($0)
    }
    
    scrollView.addSubview(contentStackView)

    contentStackView.addArrangedSubview(titleTextField)
    
    viewModel.scheduleType.forEach {
      let subStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.layer.cornerRadius = 12.5
        $0.backgroundColor = .white
      }
      
      contentStackView.addArrangedSubview(subStackView)
      
      addSubViews(stackView: subStackView, type: $0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    scrollView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.top.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide)
    }
    
    contentStackView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
      $0.width.equalTo(scrollView.snp.width)
    }
    
    titleTextField.snp.makeConstraints {
      $0.height.equalTo(56)
    }
    
    registerButton.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(26)
      $0.height.width.equalTo(46)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    setupNavigationBar()
  }
  
  override func bind() {
    super.bind()
    
  }
  
  private func setupNavigationBar() {
    title = "요란한 한줄"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "backButton"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
  }
  
  @objc
  private func didTappedBackButton() {

  }
  
  private func addSubViews(stackView: UIStackView, type: MeetingScheduleType) {
    
    let titleView = ScheduleTitleView(type: type)
    stackView.addArrangedSubview(titleView)
    
    switch type {
    case .date: // 날짜/시간
      MeetingScheduleDateType.allCases.forEach {
        let dateSubView = ScheduleDateSubView(type: $0)
        switch $0 {
        case .allDay: // 하루 종일
          dateSubView.addSubview(allDaySwitch)
          allDaySwitch.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
          }
        case .start: // 시작
          dateSubView.addSubview(startDatePicker)
          startDatePicker.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
          }
        case .end: // 종료
          dateSubView.addSubview(endDatePicker)
          endDatePicker.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
          }
        }
        stackView.addArrangedSubview(dateSubView)
      }
    case .location: // 장소
      stackView.addArrangedSubview(locationTextField)
      locationTextField.snp.makeConstraints {
        $0.height.equalTo(45)
      }
    case .alarm: // 알림
      titleView.addSubview(scheduleAlarmView)
      scheduleAlarmView.snp.makeConstraints {
        $0.edges.equalToSuperview()
      }
    case .memo: // 메모
      stackView.addArrangedSubview(memoTextView)
      memoTextView.snp.makeConstraints {
        $0.height.greaterThanOrEqualTo(45)
      }
    }
  }
}

extension MeetingScheduleViewController {
  func registerKeyboardNotification() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                             name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                             name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  func removeKeyboardNotification() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  func keyboardWillShow(_ sender: Notification) {
    if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
        view.frame.origin.y == 0 {
      let keyboardHeight: CGFloat = keyboardSize.height
      
      if UIResponder.getCurrentResponder() == titleTextField {
        registerButton.snp.updateConstraints {
          $0.bottom.equalToSuperview().inset(keyboardHeight + 26)
        }
      } else {
        view.frame.origin.y -= keyboardHeight
        scrollView.snp.updateConstraints {
          $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-72)
        }
      }
    }
  }
  
  @objc
  func keyboardWillHide(_ sender: Notification) {
    if UIResponder.getCurrentResponder() == titleTextField {
      registerButton.snp.updateConstraints {
        $0.bottom.equalToSuperview().inset(26)
      }
    } else {
      view.frame.origin.y = 0
      scrollView.snp.updateConstraints {
        $0.bottom.equalTo(view.safeAreaLayoutGuide)
      }
    }
  }
}