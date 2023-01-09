//
//  CreateMeetingListViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/09.
//

import UIKit

final class CreateMeetingListViewController: BaseViewController {
  init(currentPage: Int) {
    self.currentPage = currentPage
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var currentPage = Int() {
    didSet {
      let direction: UIPageViewController.NavigationDirection = oldValue <= currentPage ? .forward : .reverse
      pageViewController.setViewControllers(
        [viewControllers[currentPage]],
        direction: direction,
        animated: true,
        completion: nil
      )
    }
  }
  
  private let selectPeopleNumberViewController = SelectPeopleNumberViewController()
  private let selectTimeViewController = SelectTimeViewController()
  private let selectQuestionViewController = SelectQuestionViewController()
  
  private var viewControllers: [UIViewController] {
    [
      selectPeopleNumberViewController,
      selectTimeViewController,
      selectQuestionViewController
    ]
  }
  
  private lazy var pageViewController = UIPageViewController(
    transitionStyle: .scroll,
    navigationOrientation: .horizontal,
    options: nil
  ).then {
    $0.setViewControllers([viewControllers[currentPage]], direction: .forward, animated: true)
    $0.delegate = self
    $0.dataSource = self
    $0.view.translatesAutoresizingMaskIntoConstraints = false
  }
  
  private var nextButton = UIButton().then {
    $0.setTitle("Next", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.backgroundColor = .blue
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    selectPeopleNumberViewController.setupSuperView(superView: self)
    selectTimeViewController.setupSuperView(superView: self)
    selectQuestionViewController.setupSuperView(superView: self)
    
    view.addSubview(pageViewController.view)
    view.addSubview(nextButton)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    nextButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      $0.height.width.equalTo(50)
      $0.centerX.equalToSuperview()
    }
    
    pageViewController.view.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(100)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview().inset(100)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .systemBackground
    title = "\(currentPage)"
    nextButton.addTarget(self, action: #selector(didTappedNextButton), for: .touchUpInside)
  }
  
  override func bind() {
    super.bind()
  }
  
  @objc private func didTappedNextButton() {
    if currentPage + 1 >= viewControllers.count { return }
    currentPage += 1
    title = "\(currentPage)"
  }
}

extension CreateMeetingListViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let index = viewControllers.firstIndex(of: viewController),
          index - 1 >= 0 else { return nil }
    return viewControllers[index - 1]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let index = viewControllers.firstIndex(of: viewController),
          index + 1 < viewControllers.count else { return nil }
    return nil  // 우측으로 스와이프 막기
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard let viewController = pageViewController.viewControllers?[0],
          let index = viewControllers.firstIndex(of: viewController) else { return }
    currentPage = index
    title = "\(currentPage)"
  }
}
