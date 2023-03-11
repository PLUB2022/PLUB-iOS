//
//  CreateScheduleViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/18.
//

import UIKit

import SnapKit
import Then

enum MeetingScheduleType: String, CaseIterable {
  case date = "날짜/시간"
  case location = "장소"
  case alarm = "알림"
  case memo = "메모"
  
  var imageName: String {
    switch self {
    case .date:
      return "scheduleBlack"
    case .location:
      return "locationBlack"
    case .alarm:
      return "bellBlack"
    case .memo:
      return "memoBlack"
    }
  }
}

final class CreateScheduleViewController: BaseViewController {
  private let viewModel: CreateScheduleViewModel
  
  private let scrollView = UIScrollView().then {
    $0.bounces = false
    $0.showsVerticalScrollIndicator = false
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 33
  }
  
  private let titleTextField = PaddingTextField(left: 12, right: 12).then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 12.5
    $0.attributedPlaceholder = NSAttributedString(
      string: Constants.titlePlaceHolder,
      attributes: [
        .foregroundColor : UIColor.mediumGray,
        .font: UIFont.h5
      ]
    )
    $0.textColor = .black
    $0.font = .h5
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
  
  private let locationButton = UIButton(configuration: .plain()).then {
    $0.configuration?.contentInsets = NSDirectionalEdgeInsets(
      top: 12.5,
      leading: 12.5,
      bottom: 12.5,
      trailing: 12.5
    )
    $0.contentHorizontalAlignment = .leading
    $0.configuration?.baseForegroundColor = .mediumGray
    $0.configuration?.title = Constants.locationPlaceHolder
    $0.configuration?.font = UIFont.appFont(family: .pretendard(option: .regular), size: 14)
  }
  
  private let memoTextView = UITextView().then {
    $0.textContainerInset = UIEdgeInsets(
      top: 12.5,
      left: 12.5,
      bottom: 12.5,
      right: 12.5
    )
    $0.isScrollEnabled = false
    $0.textColor = .mediumGray
    $0.font = UIFont.appFont(family: .pretendard(option: .regular), size: 14)
    $0.text = Constants.memoPlaceHolder
    $0.backgroundColor = .clear
  }
  
  private lazy var scheduleAlarmView = ScheduleAlarmView().then {
    $0.delegate = self
  }
  
  private let registerButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "일정 등록")
    $0.isEnabled = false
  }
  
  private let tapGesture = UITapGestureRecognizer(
    target: CreateScheduleViewController.self,
    action: nil
  ).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  init(plubbingID: Int) {
    viewModel = CreateScheduleViewModel(plubbingID: plubbingID)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
    
    titleTextField.rx.text.orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.title)
      .disposed(by: disposeBag)
    
    titleTextField.rx.controlEvent([.editingDidEndOnExit])
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)
    
    allDaySwitch.rx.value
      .asDriver()
      .drive(with: self) { owner, value in
        owner.changeDatePickerMode(with: value)
        owner.viewModel.allDay.onNext(value)
      }
      .disposed(by: disposeBag)
    
    startDatePicker.rx.value
      .bind(to: viewModel.startDate)
      .disposed(by: disposeBag)
    
    endDatePicker.rx.value
      .bind(to: viewModel.endDate)
      .disposed(by: disposeBag)
    
    locationButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.view.endEditing(true)
        let vc = LocationBottomSheetViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = owner
        owner.parent?.present(vc, animated: false)
      }
      .disposed(by: disposeBag)
    
    memoTextView.rx.didBeginEditing
      .asDriver()
      .drive(with: self) { owner, _ in
        guard owner.memoTextView.text == Constants.memoPlaceHolder else { return }
        owner.memoTextView.text = nil
        owner.memoTextView.textColor = .black
      }
      .disposed(by: disposeBag)
    
    memoTextView.rx.didEndEditing
      .asDriver()
      .drive(with: self) { owner, _ in
        guard owner.memoTextView.text.isEmpty else { return }
        owner.memoTextView.text = Constants.memoPlaceHolder
        owner.memoTextView.textColor = .lightGray
      }
      .disposed(by: disposeBag)
    
    memoTextView.rx.text.orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.memo)
      .disposed(by: disposeBag)
    
    registerButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.viewModel.createSchedule()
      }
      .disposed(by: disposeBag)
    
    viewModel.isButtonEnabled
      .drive(registerButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    viewModel.successResult
      .drive(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
    
    tapGesture.rx.event
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)
    
    scrollView.addGestureRecognizer(tapGesture)
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
    navigationController?.popViewController(animated: true)
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
          dateSubView.addDateSubview(allDaySwitch)
          
        case .start: // 시작
          dateSubView.addDateSubview(startDatePicker)
          
        case .end: // 종료
          dateSubView.addDateSubview(endDatePicker)
        }
        
        stackView.addArrangedSubview(dateSubView)
      }
      
    case .location: // 장소
      stackView.addArrangedSubview(locationButton)
      locationButton.snp.makeConstraints {
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
  
  private func changeDatePickerMode(with value: Bool) {
    if value {
      startDatePicker.datePickerMode = .date
      endDatePicker.datePickerMode = .date
    } else {
      startDatePicker.datePickerMode = .dateAndTime
      endDatePicker.datePickerMode = .dateAndTime
    }
  }
}

extension CreateScheduleViewController {
  func registerKeyboardNotification() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow(_:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide(_:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
  func removeKeyboardNotification() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  func keyboardWillShow(_ sender: Notification) {
    let currentResponder = UIResponder.getCurrentResponder()
    
    guard (currentResponder == titleTextField) ||
          (currentResponder == memoTextView) else { return }
    
    if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
      view.frame.origin.y == 0 {
      let keyboardHeight: CGFloat = keyboardSize.height
      
      if currentResponder == titleTextField {
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
    let currentResponder = UIResponder.getCurrentResponder()
    
    guard (currentResponder == titleTextField) ||
          (currentResponder == memoTextView) else { return }
    
    if currentResponder == titleTextField {
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

extension CreateScheduleViewController {
  struct Constants {
    static let titlePlaceHolder = "일정 제목을 입력해 주세요."
    static let locationPlaceHolder = "장소를 입력해 주세요"
    static let memoPlaceHolder = "메모 내용을 입력해주세요."
  }
}

extension CreateScheduleViewController: LocationBottomSheetDelegate {
  func selectLocation(location: Location) {
    locationButton.configuration?.baseForegroundColor = .black
    locationButton.configuration?.title = location.placeName
    locationButton.configuration?.font = UIFont.appFont(family: .pretendard(option: .regular), size: 14)
    viewModel.location.onNext(location)
  }
}

extension CreateScheduleViewController: ScheduleAlarmDelegate {
  func selectAlarm(alarm: ScheduleAlarmType) {
    viewModel.alarm.onNext(alarm)
  }
}
