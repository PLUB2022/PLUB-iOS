//
//  MeetingNameViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/08.
//

import UIKit

import RxSwift
import SnapKit

protocol CreateMeetingChildViewControllerDelegate : AnyObject {
  func checkValidation(index:Int, state : Bool)
}

final class MeetingNameViewController: BaseViewController {
  
  // MARK: - Property
  private var viewModel: MeetingNameViewModel
  weak var delegate: CreateMeetingChildViewControllerDelegate?
  private var childIndex: Int
  
  private let scrollView = UIScrollView().then {
    $0.bounces = false
    $0.contentInsetAdjustmentBehavior = .never
    $0.showsVerticalScrollIndicator = false
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 48
  }
  
  private let titleView = CreateMeetingTitleView(
    title: "이 모임을 뭐라고 부를까요?",
    description: "소개 타이틀, 모임 이름을 적어주세요."
  )
    
  private let introduceTitleView = InputTextView(
    title: "소개 타이틀",
    placeHolder: "소개하는 내용을 입력해주세요",
    options: [.textCount, .questionMark]
  )
  
  private let nameTitleView = InputTextView(
    title: "모임 이름",
    placeHolder: "우리동네 사진모임",
    options: [.textCount, .questionMark],
    totalCharacterLimit: 60
  )
  
  private let tapGesture = UITapGestureRecognizer(
    target: MeetingNameViewController.self,
      action: nil
  ).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  init(
    viewModel: MeetingNameViewModel,
    childIndex: Int
  ) {
    self.viewModel = viewModel
    self.childIndex = childIndex
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(contentStackView)
    
    [titleView, introduceTitleView, nameTitleView].forEach {
      contentStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    scrollView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.leading.trailing.bottom.equalToSuperview().inset(24)
    }
    
    contentStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalTo(scrollView.snp.width)
    }
    
    contentStackView.setCustomSpacing(43, after: introduceTitleView)
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
    
    let input = MeetingNameViewModel.Input(
      introduceTitleText: introduceTitleView.textView.rx.text.orEmpty.asObservable(),
      nameTitleText: nameTitleView.textView.rx.text.orEmpty.asObservable()
    )
            
    let output = viewModel.transform(input: input)
    
    output.isBtnEnabled
      .distinctUntilChanged()
      .drive(onNext: { [weak self] in
        guard let self = self else { return }
        self.delegate?.checkValidation(
          index: self.childIndex,
          state: $0
        )
      })
      .disposed(by: disposeBag)

    tapGesture.rx.event
      .asDriver()
      .drive(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.view.endEditing(true)
      })
      .disposed(by: disposeBag)
    
    scrollView.addGestureRecognizer(tapGesture)
  }
}
