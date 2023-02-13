//
//  EditMeetingViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/09.
//

import UIKit

import SnapKit
import Then

protocol EditMeetingChildViewControllerDelegate : AnyObject {
  func checkValidation(index:Int, state : Bool)
}

enum EditMeetingType: CaseIterable {
  case meetingPost
  case meetingInfo
  case meetingQuestion
}

final class EditMeetingViewController: BaseViewController {
  private let viewModel: EditMeetingViewModel
  private let segmentedControl = UnderlineSegmentedControl(
    items: ["모집글", "모임 정보", "게스트 질문"]
  ).then {
    $0.setTitleTextAttributes([.foregroundColor: UIColor.black, .font: UIFont.h5!], for: .normal)
    $0.setTitleTextAttributes([.foregroundColor: UIColor.main, .font: UIFont.h5!], for: .selected)
    $0.selectedSegmentIndex = 0
  }
  
  private lazy var pageViewController = UIPageViewController(
    transitionStyle: .scroll,
    navigationOrientation: .horizontal,
    options: nil
  ).then {
      $0.setViewControllers([viewControllers[0]], direction: .forward, animated: true)
      $0.delegate = self
      $0.dataSource = self
  }
  
  private let saveButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "저장")
  }
  
  private lazy var recruitPostViewController = RecruitPostViewController(viewModel: viewModel.recruitPostViewModel).then {
    $0.delegate = self
  }
  private lazy var meetingInfoViewController = MeetingInfoViewController(viewModel: viewModel.meetingInfoViewModel).then {
    $0.delegate = self
  }
  private lazy var guestQuestionViewController = GuestQuestionViewController(viewModel: viewModel.guestQuestionViewModel).then {
    $0.delegate = self
  }
  
  private var viewControllers: [UIViewController] {
    [recruitPostViewController, meetingInfoViewController, guestQuestionViewController]
  }
  
  var currentPage = 0 {
    didSet {
      let direction: UIPageViewController.NavigationDirection = oldValue <= currentPage ? .forward : .reverse
      pageViewController.setViewControllers(
          [viewControllers[currentPage]], direction: direction, animated: true
      )
      saveButton.isEnabled = isSaveButtonEnable[currentPage]
    }
  }
  
  private var isSaveButtonEnable = [true, true, true]
  
  init(plubbingID: String) {
    viewModel = EditMeetingViewModel(plubbingID: plubbingID)
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

    [segmentedControl, pageViewController.view, saveButton].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    segmentedControl.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.height.equalTo(52)
    }
    
    pageViewController.view.snp.makeConstraints {
      $0.top.equalTo(segmentedControl.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
    
    saveButton.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(26)
      $0.height.width.equalTo(46)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
    
    segmentedControl.rx.value
      .asDriver()
      .drive(with: self) { owner, index in
        owner.currentPage = index
      }
      .disposed(by: disposeBag)
    
    saveButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        switch EditMeetingType.allCases[owner.currentPage] {
        case .meetingPost:
          owner.viewModel.recruitPostViewModel.editMeetingPost()
        case .meetingInfo:
          owner.viewModel.meetingInfoViewModel.requestEditMeeting()
        case .meetingQuestion:
          owner.viewModel.guestQuestionViewModel.requestEditMeeting()
        }
      }
      .disposed(by: disposeBag)
  }
}

extension EditMeetingViewController: EditMeetingChildViewControllerDelegate {
  func checkValidation(index:Int, state: Bool) {
    isSaveButtonEnable[index] = state
    saveButton.isEnabled = isSaveButtonEnable[currentPage]
  }
}

extension EditMeetingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let index = viewControllers.firstIndex(of: viewController),
          index - 1 >= 0 else { return nil }
    return viewControllers[index - 1]
  }

  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let index = viewControllers.firstIndex(of: viewController),
          index + 1 < viewControllers.count else { return nil }
    return viewControllers[index + 1]
  }
    
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard let viewController = pageViewController.viewControllers?[0],
          let index = viewControllers.firstIndex(of: viewController) else { return }
    currentPage = index
    segmentedControl.selectedSegmentIndex = index
  }
}

extension EditMeetingViewController {
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
    if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      let keyboardHeight: CGFloat = keyboardSize.height
      saveButton.snp.updateConstraints {
        $0.bottom.equalToSuperview().inset(keyboardHeight + 26)
      }
      view.layoutIfNeeded()
    }
  }
  
  @objc
  func keyboardWillHide(_ sender: Notification) {
    saveButton.snp.updateConstraints {
      $0.bottom.equalToSuperview().inset(26)
    }
    view.layoutIfNeeded()
  }
}
