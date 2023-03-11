//
//  MainPageViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/01.
//

import UIKit

import SnapKit
import Then
/// 메인페이지 탑 탭바 타입
enum MainPageFilterType {
  case board
  case todoList
  
  var title: String {
    switch self {
    case .board:
      return "게시글"
    case .todoList:
      return "그룹원 TO-DO 리스트"
    }
  }
}

final class MainPageViewController: BaseViewController {
  
  var currentPage = 0 {
    didSet {
      let direction: UIPageViewController.NavigationDirection = oldValue <= currentPage ? .forward : .reverse
      pageViewController.setViewControllers(
        [viewControllers[currentPage]], direction: direction, animated: true
      )
    }
  }
  
  private lazy var headerView = MainPageHeaderView().then {
    $0.backgroundColor = .red
    $0.layer.masksToBounds = true
    $0.clipsToBounds = true
    $0.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
    $0.delegate = self
  }
  
  private let segmentedControl = UnderlineSegmentedControl(
    items: [MainPageFilterType.board.title, MainPageFilterType.todoList.title]
  ).then {
    $0.setTitleTextAttributes([.foregroundColor: UIColor.mediumGray, .font: UIFont.body1], for: .normal)
    $0.setTitleTextAttributes([.foregroundColor: UIColor.main, .font: UIFont.body1], for: .selected)
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
  
  private lazy var boardViewController = BoardViewController().then {
    $0.delegate = self
  }
  private let todolistViewController = TodolistViewController()
  
  private var viewControllers: [UIViewController] {
    [boardViewController, todolistViewController]
  }
  
  private let writeButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "+ 새 글 작성")
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
  }
  
  private lazy var mainpageNavigationView = MainPageNavigationView().then {
    $0.axis = .horizontal
    $0.spacing = 4
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "back"),
      style: .done,
      target: self,
      action: #selector(didTappedBackButton)
    )
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: mainpageNavigationView)
    title = "요란한 밧줄"
    
    let scrollView = pageViewController.view.subviews
      .compactMap { $0 as? UIScrollView }
      .first
    
    scrollView?.delegate = self
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [headerView, segmentedControl, pageViewController.view, writeButton].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    headerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(292)
    }
    
    segmentedControl.snp.makeConstraints {
      $0.top.equalTo(headerView.snp.bottom).offset(16)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(32)
    }
    
    pageViewController.view.snp.makeConstraints {
      $0.top.equalTo(segmentedControl.snp.bottom)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
    
    writeButton.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(24)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(110)
      $0.height.equalTo(32)
    }
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
  
  @objc func didTappedBackButton() {
    self.navigationController?.popViewController(animated: true)
  }
}

extension MainPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    //    guard let index = viewControllers.firstIndex(of: viewController),
    //          index - 1 >= 0 else { return nil }
    //    return viewControllers[index - 1]
    return nil
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    //    guard let index = viewControllers.firstIndex(of: viewController),
    //          index + 1 < viewControllers.count else { return nil }
    //    return viewControllers[index + 1]
    return nil
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard let viewController = pageViewController.viewControllers?[0],
          let index = viewControllers.firstIndex(of: viewController) else { return }
    currentPage = index
    segmentedControl.selectedSegmentIndex = index
  }
}

extension MainPageViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    let currentPageIndex = viewControllers
      .enumerated()
      .first(where: { _, vc in vc == pageViewController.viewControllers?.first })
      .map(\.0) ?? 0
    
    let isFirstable = currentPageIndex == 0
    let isLastable = currentPageIndex == viewControllers.count - 1
    let shouldDisableBounces = isFirstable || isLastable
    scrollView.bounces = !shouldDisableBounces
  }
}

extension MainPageViewController: BoardViewControllerDelegate {
  func calculateHeight(_ height: CGFloat) {
    headerView.snp.updateConstraints {
      $0.height.equalTo(height)
    }
    if height == Device.navigationBarHeight {
      self.navigationController?.navigationBar.isHidden = false
      self.headerView.isHidden = true
      headerView.snp.updateConstraints {
        $0.height.equalTo(0)
      }
    } else {
      self.navigationController?.navigationBar.isHidden = true
      self.headerView.isHidden = false
    }
  }
}

extension MainPageViewController: MainPageHeaderViewDelegate {
  func didTappedMainPageBackButton() {
    self.navigationController?.popViewController(animated: true)
  }
}
