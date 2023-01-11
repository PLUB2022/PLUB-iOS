//
//  CreateMeetingViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/11.
//

import UIKit

final class CreateMeetingViewController: BaseViewController {
  
  init(totalPage: Int) {
    self.totalPage = totalPage
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var currentPage = Int() {
    didSet {
      pageControl.currentPage = currentPage
    }
  }
  
  var totalPage = Int() {
    didSet {
      scrollView.contentSize.width = screenWidth * CGFloat(totalPage)
      if oldValue < totalPage {
        pushChildView(totalPage: totalPage)
      }else {
        popChildView(totalPage: totalPage)
      }
    }
  }
  
  private lazy var pageControl = PageControl().then {
    $0.numberOfPages = viewControllers.count
    $0.currentPage = 0
  }
  
  private lazy var scrollView = UIScrollView().then {
    $0.bounces = false
    $0.contentInsetAdjustmentBehavior = .never
    $0.isPagingEnabled = true
    $0.contentSize.width = screenWidth
    $0.showsHorizontalScrollIndicator = false
    $0.delegate = self
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 0
  }
  
  private let selectPeopleNumberView = UIView()
  private let selectTimeView = UIView()
  private let selectQuestionView = UIView()
  
  private var containerViews: [UIView] {
    [
      selectPeopleNumberView,
      selectTimeView,
      selectQuestionView
    ]
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
  
  private var nextButton = UIButton().then {
    $0.setTitle("Next", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.backgroundColor = .blue
  }
  
  let screenWidth = UIScreen.main.bounds.size.width
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    addChild(selectPeopleNumberViewController)
    addChild(selectTimeViewController)
    
    view.addSubview(pageControl)
    view.addSubview(scrollView)
    view.addSubview(nextButton)
    
    scrollView.addSubview(contentStackView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    pageControl.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(36)
      $0.leading.equalToSuperview().inset(16)
      $0.height.equalTo(8)
    }
    
    scrollView.snp.makeConstraints {
      $0.top.equalTo(pageControl.snp.bottom).offset(16)
      $0.leading.trailing.bottom.equalToSuperview()
    }
    
    contentStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.height.equalTo(scrollView.snp.height)
    }
    
    nextButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      $0.height.width.equalTo(50)
      $0.centerX.equalToSuperview()
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .systemBackground
    nextButton.addTarget(self, action: #selector(didTappedNextButton), for: .touchUpInside)
    pushChildView(totalPage: totalPage)
  }
  
  override func bind() {
    super.bind()
  }
  
  @objc private func didTappedNextButton() {
    guard totalPage + 1 < viewControllers.count else { return }
    totalPage += 1
    currentPage = totalPage
  }
  
  private func pushChildView(totalPage: Int) {
    contentStackView.addArrangedSubview(containerViews[totalPage])
    containerViews[totalPage].addSubview(viewControllers[totalPage].view)
    
    containerViews[totalPage].snp.makeConstraints {
      $0.width.equalTo(screenWidth)
    }
    
    viewControllers[totalPage].view.snp.makeConstraints {
      $0.leading.trailing.top.bottom.equalToSuperview().inset(10)
    }
    
    scrollToPage(page: totalPage)
  }
  
  //TODO: 수빈 - 이전 뷰의 값이 다 채워지지 않을 경우, 다음 뷰 pop 로직 추가하기
  private func popChildView(totalPage: Int) {
    
  }
  
  private func scrollToPage(page: Int) {
    let offset: CGPoint = CGPoint(x: screenWidth * CGFloat(page), y: 0)
    scrollView.setContentOffset(offset, animated: true)
  }
}

extension CreateMeetingViewController: UIScrollViewDelegate {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let width = scrollView.frame.width
    let page = Int(round(scrollView.contentOffset.x/width))
    currentPage = page
  }
}
