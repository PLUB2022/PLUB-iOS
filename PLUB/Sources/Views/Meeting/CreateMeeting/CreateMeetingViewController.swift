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
  
  private lazy var scrollView = UIScrollView().then {
    $0.bounces = false
    $0.contentInsetAdjustmentBehavior = .never
    $0.isPagingEnabled = true
    $0.contentSize.width = screenWidth
    $0.showsHorizontalScrollIndicator = false
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
    
    view.addSubview(scrollView)
    view.addSubview(nextButton)
    
    scrollView.addSubview(contentStackView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    scrollView.snp.makeConstraints {
        $0.top.equalTo(view.safeAreaLayoutGuide)
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
    guard totalPage < viewControllers.count else { return }
    totalPage += 1
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
  
  private func popChildView(totalPage: Int) {
    
  }
  
  private func scrollToPage(page: Int) {
    let offset: CGPoint = CGPoint(x: screenWidth * CGFloat(page), y: 0)
    scrollView.setContentOffset(offset, animated: true)
  }
}

