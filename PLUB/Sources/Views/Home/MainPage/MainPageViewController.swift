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
enum MainPageFilterType: CaseIterable {
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
  
  var buttonTitle: String {
    switch self {
    case .board:
      return "+ 새 글 작성"
    case .todoList:
      return "+ TO-DO 플래너"
    }
  }
}

final class MainPageViewController: BaseViewController {
  
  private let plubbingID: Int
  private let goal: String
  
  var currentPage = 0 {
    didSet {
      let direction: UIPageViewController.NavigationDirection = oldValue <= currentPage ? .forward : .reverse
      pageViewController.setViewControllers(
        [viewControllers[currentPage]], direction: direction, animated: true
      )
      
      writeButton.configurationUpdateHandler = writeButton.configuration?.plubButton(label: MainPageFilterType.allCases[currentPage].buttonTitle)
    }
  }
  
  private let segmentedControl = UnderlineSegmentedControl(
    items: MainPageFilterType.allCases.map { $0.title }
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
  
  private lazy var boardViewController = BoardViewController(plubbingID: plubbingID).then {
    $0.delegate = self
  }
  
  private lazy var todolistViewController = TodolistViewController(plubbingID: plubbingID, goal: goal).then {
    $0.delegate = self
  }
  
  private var viewControllers: [UIViewController] {
    [
      boardViewController,
      todolistViewController
    ]
  }
  
  private let writeButton = UIButton(configuration: .plain()).then {
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
  }
  
  private lazy var mainpageNavigationView = MainPageNavigationView().then {
    $0.axis = .horizontal
    $0.spacing = 4
    $0.delegate = self
  }
  
  init(plubbingID: Int, goal: String) {
    self.plubbingID = plubbingID
    self.goal = goal
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.isHidden = false
  }
  
  override func setupStyles() {
    super.setupStyles()
    navigationItem.title = title
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: mainpageNavigationView)
    
    let scrollView = pageViewController.view.subviews
      .compactMap { $0 as? UIScrollView }
      .first
    
    scrollView?.delegate = self
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [segmentedControl, pageViewController.view, writeButton].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    segmentedControl.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalTo(view.safeAreaLayoutGuide)
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
      $0.width.greaterThanOrEqualTo(110)
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
    
    writeButton.rx.tap
      .subscribe(with: self) { owner, _ in
        if owner.currentPage == 0 {
          let vc = WriteBoardViewController(plubbingID: owner.plubbingID)
          vc.navigationItem.largeTitleDisplayMode = .never
          vc.title = owner.title
          owner.navigationController?.pushViewController(vc, animated: true)
        }
        else {
          let vc = TodoPlannerViewController(plubbingID: owner.plubbingID)
          vc.navigationItem.largeTitleDisplayMode = .never
          vc.title = owner.title
          owner.navigationController?.pushViewController(vc, animated: true)
        }
      }
      .disposed(by: disposeBag)
  }
}

extension MainPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    return nil
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
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
  func didTappedModifyBoard(model: BoardModel) {
    let vc = WriteBoardViewController(plubbingID: plubbingID, createBoardType: .modify) { [weak self] request in
      guard let self = self else { return }
      self.boardViewController.requestUpdateBoard(request: request)
    }
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.title = title
    vc.updateForModify(model: model)
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func didTappedBoardClipboardHeaderView() {
    let vc = ClipboardViewController(viewModel: ClipboardViewModel(plubbingID: plubbingID))
    vc.title = title
    vc.navigationItem.largeTitleDisplayMode = .never
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func didTappedBoardCollectionViewCell(plubbingID: Int, content: BoardModel) {
    let vc = BoardDetailViewController(
      viewModel: BoardDetailViewModelWithFeedsFactory.make(plubbingID: plubbingID, feedID: content.feedID)
    )
    vc.title = title
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
}

extension MainPageViewController: MainPageNavigationViewDelegate {
  func didTappedArchiveButton() {
    let vc = ArchiveViewController(
      viewModel: ArchiveViewModel(
        plubbingID: plubbingID,
        getArchiveUseCase: DefaultGetArchiveUseCase(),
        deleteArchiveUseCase: DefaultDeleteArchiveUseCase(plubbingID: plubbingID)
      )
    )
    vc.title = title
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func didTappedNoticeButton() {
    let vc = NotificationViewController(viewModel: NotificationViewModel())
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.title = title
    navigationController?.pushViewController(vc, animated: true)
  }
}

extension MainPageViewController: TodolistDelegate {
  func didTappedTodoPlanner(date: Date) {
    let vc = TodoPlannerViewController(plubbingID: plubbingID, type: .manageMyPlanner(date))
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.title = title
    self.navigationController?.pushViewController(vc, animated: true)
  }
}
