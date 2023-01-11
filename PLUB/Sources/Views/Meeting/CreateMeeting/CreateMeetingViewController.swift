//
//  CreateMeetingViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/11.
//

import UIKit

import RxSwift

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
  
  private var nextButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "다음")
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
      $0.bottom.equalToSuperview().inset(26)
      $0.height.width.equalTo(46)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .systemBackground
    pushChildView(totalPage: totalPage)
  }
  
  override func bind() {
    super.bind()
    nextButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        guard owner.totalPage + 1 < owner.viewControllers.count else { return }
        owner.totalPage += 1
        owner.currentPage = owner.totalPage
      })
      .disposed(by: disposeBag)
  }

  private func pushChildView(totalPage: Int) {
    contentStackView.addArrangedSubview(containerViews[totalPage])
    containerViews[totalPage].addSubview(viewControllers[totalPage].view)
    
    containerViews[totalPage].snp.makeConstraints {
      $0.width.equalTo(screenWidth)
    }
    
    viewControllers[totalPage].view.snp.makeConstraints {
      $0.leading.trailing.top.bottom.equalToSuperview()
    }
    
    scrollToPage(page: totalPage)
  }
  
  //TODO: 수빈 - 이전 VC 값 수정 시, nextButton disable 될 때 다음 VC pop 로직 추가하기
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
