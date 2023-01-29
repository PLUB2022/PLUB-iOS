//
//  SignUpViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/19.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

protocol SignUpChildViewControllerDelegate: BaseViewController {
  func checkValidation(index: Int, state: Bool)
  
  func information(categories: [Int])
  func information(profile image: UIImage)
  func information(birth date: Date)
  func information(sex: Sex)
  func information(introduction: String)
  func information(nickname: String)
  func information(policies: [Bool])
}

final class SignUpViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let viewModel = SignUpViewModel()
  
  private var currentPage = 0 {
    didSet {
      view.endEditing(true)
      pageControl.currentPage = currentPage
      updateTitles(index: currentPage)
      setRightNavigationItem(index: currentPage)
    }
  }
  
  private var lastPageIndex = 0 {
    didSet {
      view.endEditing(true)
      
      contentStackView.addArrangedSubview(viewControllers[lastPageIndex].view)
      viewControllers[lastPageIndex].view.snp.makeConstraints {
        $0.width.equalTo(view.snp.width)
      }
      viewModel.validationState.onNext(ValidationState(index: lastPageIndex, state: false))
    }
  }
  
  private lazy var viewControllers = [
    PolicyViewController().then { $0.delegate = self },
    BirthViewController().then { $0.delegate = self },
    ProfileViewController().then { $0.delegate = self },
    IntroductionViewController().then { $0.delegate = self },
    InterestViewController().then { $0.delegate = self }
  ]
  
  // MARK: UI Properties
  
  private let stackView = UIStackView().then {
    $0.alignment = .leading
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private lazy var pageControl = PageControl().then {
    $0.numberOfPages = viewControllers.count
  }
  
  private lazy var titleLabel = UILabel().then {
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.attributedText = viewModel.titles[currentPage]
    $0.font = .h4
  }
  
  private lazy var subtitleLabel = UILabel().then {
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.attributedText = viewModel.subtitles[currentPage]
    $0.font = .body2
  }
  
  private lazy var scrollView = UIScrollView().then {
    $0.bounces = false
    $0.isPagingEnabled = true
    $0.showsHorizontalScrollIndicator = false
    $0.delegate = self
  }
  
  private let contentStackView = UIStackView().then {
    $0.backgroundColor = .background
  }
  
  private var nextButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "다음")
  }
  
  // MARK: - Life Cycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerKeyboardNotification()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeKeyboardNotification()
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    
    viewControllers.forEach { addChild($0) }
    
    [stackView, scrollView, nextButton].forEach {
      view.addSubview($0)
    }
    
    scrollView.addSubview(contentStackView)
    
    
    contentStackView.addArrangedSubview(viewControllers.first!.view)
    
    [pageControl, titleLabel, subtitleLabel].forEach {
      stackView.addArrangedSubview($0)
    }
    viewControllers.forEach { $0.didMove(toParent: self) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    stackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(28)
      $0.horizontalEdges.equalToSuperview().inset(24)
    }
    
    scrollView.snp.makeConstraints {
      $0.top.equalTo(stackView.snp.bottom).offset(48)
      $0.horizontalEdges.bottom.equalToSuperview()
    }
    
    contentStackView.snp.makeConstraints {
      $0.edges.equalTo(scrollView.contentLayoutGuide)
      $0.height.equalTo(scrollView.snp.height)
      $0.width.greaterThanOrEqualToSuperview().priority(.low)
    }
    
    viewControllers.first!.view.snp.makeConstraints {
      $0.width.equalTo(view.snp.width)
    }
    
    nextButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(4)
      $0.horizontalEdges.equalToSuperview().inset(24)
      $0.height.equalTo(48)
    }
    
    stackView.setCustomSpacing(24, after: pageControl)
  }
  
  override func setupStyles() {
    super.setupStyles()
    setupNavigationBar()
  }
  
  override func bind() {
    super.bind()
    let nextButtonShareObservable = nextButton.rx.tap
      .share()
      .withUnretained(self)
    
    // 유저가 필요한 정부를 전부 기입했을 때 회원가입 진행
    nextButtonShareObservable
      .filter { owner, _ in return owner.lastPageIndex + 1 == owner.viewControllers.count }
      .flatMap { owner, _ in return owner.viewModel.signUp() }
      .withUnretained(self)
      .subscribe(onNext: { owner, succeed in
        if succeed {
          owner.navigationController?.setViewControllers([HomeViewController(viewModel: HomeViewModel())], animated: true)
        } else {
          print("회원가입 실패")
        }
      })
      .disposed(by: disposeBag)
    
    // 아직 유저가 필요한 정보를 전부 기입하지 못한 경우(남은 페이지가 있는 경우를 뜻함)
    nextButtonShareObservable
      .subscribe(onNext: { owner, _ in
        if owner.currentPage < owner.lastPageIndex {
          owner.currentPage += 1
        } else if owner.lastPageIndex + 1 < owner.viewControllers.count {
          owner.lastPageIndex += 1
          owner.currentPage = owner.lastPageIndex
        }
        owner.scrollToPage(index: owner.currentPage)
      })
      .disposed(by: disposeBag)
    
    viewModel.isButtonEnabled
      .drive(nextButton.rx.isEnabled)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Custom Methods
  
  /// 네비게이션바 세팅 메서드
  private func setupNavigationBar() {
    navigationController?.navigationBar.tintColor = .black
    navigationController?.navigationBar.backgroundColor = .background
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "backButton"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
  }
  
  /// 네비게이션 바의 back 버튼 클릭 시 처리
  @objc
  private func didTappedBackButton() {
    if currentPage == 0 {
      navigationController?.popViewController(animated: true)
    } else {
      currentPage -= 1
      scrollToPage(index: currentPage)
    }
  }
  
  /// index에 맞는 페이지로 스크롤
  private func scrollToPage(index: Int) {
    let offset: CGPoint = CGPoint(x: view.frame.width * CGFloat(index), y: 0)
    scrollView.setContentOffset(offset, animated: true)
  }
  
  private func updateTitles(index: Int) {
    titleLabel.attributedText = viewModel.titles[index]
    subtitleLabel.attributedText = viewModel.subtitles[index]
  }
  
  private func setRightNavigationItem(index: Int) {
    // 마지막 페이지가 아닌 경우 right button item 없앰
    if index + 1 != viewControllers.count {
      navigationItem.rightBarButtonItem = UIBarButtonItem()
      return
    }
    // `다음에 하기` 버튼 생성
    let button = UIButton().then {
      $0.setTitle("다음에 하기", for: .normal)
      $0.setTitleColor(.deepGray, for: .normal)
      $0.titleLabel?.font = .body1
      // action으로 회원가입 파트 바로 진행
      $0.addAction(UIAction { [weak self] _ in
        guard let self else { return }
        self.viewModel.signUp()
          .subscribe(onNext: { succeed in
            if succeed {
              self.navigationController?.setViewControllers([HomeViewController(viewModel: HomeViewModel())], animated: true)
            } else {
              print("회원가입 실패")
            }
          })
          .disposed(by: self.disposeBag)
      }, for: .touchUpInside)
    }
    
    // 버튼 등록
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
  }
}

// MARK: - Keyboard

extension SignUpViewController {
  func registerKeyboardNotification() {
    NotificationCenter.default.addObserver(
      self, selector: #selector(keyboardWillShow(_:)),
      name: UIResponder.keyboardWillShowNotification, object: nil
    )
    NotificationCenter.default.addObserver(
      self, selector: #selector(keyboardWillHide(_:)),
      name: UIResponder.keyboardWillHideNotification, object: nil
    )
  }
  
  func removeKeyboardNotification() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  func keyboardWillShow(_ sender: Notification) {
    if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      let keyboardHeight: CGFloat = keyboardSize.height
      nextButton.snp.updateConstraints {
        $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(keyboardHeight + 4)
      }
      view.layoutIfNeeded()
    }
  }
  
  @objc
  func keyboardWillHide(_ sender: Notification) {
    nextButton.snp.updateConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(4)
    }
    view.layoutIfNeeded()
  }
}

// MARK: - UIScrollViewDelegate

extension SignUpViewController: UIScrollViewDelegate {
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    // 스와이프로 페이지 이동했을 때 보이는 페이지 index를 세팅
    if velocity.x > 0 { // move right
      currentPage = lastPageIndex == currentPage ? lastPageIndex : currentPage + 1
    } else if velocity.x < 0 { // move left
      currentPage = currentPage == 0 ? 0 : currentPage - 1
    }
  }
}

// MARK: - SignUpChildViewControllerDelegate

extension SignUpViewController: SignUpChildViewControllerDelegate {
  func checkValidation(index: Int, state: Bool) {
    viewModel.validationState.onNext(ValidationState(index: index, state: state))
  }
  
  func information(categories: [Int]) {
    viewModel.categories.onNext(categories)
  }
  
  func information(profile image: UIImage) {
    viewModel.profileImage.onNext(image)
  }
  
  func information(birth date: Date) {
    viewModel.birth.onNext(date)
  }
  
  func information(sex: Sex) {
    viewModel.sex.onNext(sex)
  }
  
  func information(introduction: String) {
    viewModel.introduction.onNext(introduction)
  }
  
  func information(nickname: String) {
    viewModel.nickname.onNext(nickname)
  }
  
  func information(policies: [Bool]) {
    viewModel.policies.onNext(policies)
  }
}
