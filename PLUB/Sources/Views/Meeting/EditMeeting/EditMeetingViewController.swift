//
//  EditMeetingViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/09.
//

import UIKit

final class EditMeetingViewController: BaseViewController {
  
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
  
  private let recruitPostViewController = RecruitPostViewController()
  private let meetingInfoViewController = MeetingInfoViewController()
  private let guestQuestionViewController = GuestQuestionViewController()
  
  private var viewControllers: [UIViewController] {
      [recruitPostViewController, meetingInfoViewController, guestQuestionViewController]
  }
  
  var currentPage = 0 {
    didSet {
      let direction: UIPageViewController.NavigationDirection = oldValue <= currentPage ? .forward : .reverse
      pageViewController.setViewControllers(
          [viewControllers[currentPage]], direction: direction, animated: true
      )
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func setupLayouts() {
    super.setupLayouts()

    [segmentedControl, pageViewController.view].forEach {
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
