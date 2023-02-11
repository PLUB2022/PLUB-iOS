//
//  RecruitPostViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/10.
//

import UIKit

final class RecruitPostViewController: BaseViewController {
  private let viewModel: RecruitPostViewModel
  
  
  private let scrollView = UIScrollView().then {
    $0.bounces = false
    $0.showsVerticalScrollIndicator = false
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 40
  }
  
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
  
  private let goalView = InputTextView(
    title: "모임 목표",
    placeHolder: "소개하는 내용을 입력해주세요",
    options: [.textCount]
  )
  
  private let introduceView = InputTextView(
    title: "모임 소개글",
    placeHolder: "우리동네 사진모임"
  )
  
  private let photoStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }

  private let photoTitleLabel = UILabel().then {
    $0.font = .subtitle
    $0.textColor = .black
    $0.text = "모임 소개 사진 (선택)"
  }

  private let photoSelectView = PhotoSelectView()
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  private let tapGesture = UITapGestureRecognizer(
    target: RecruitPostViewController.self,
      action: nil
  ).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }

  init(plubbingID: String) {
    viewModel = RecruitPostViewModel(plubbingID: plubbingID)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(contentStackView)
    
    [introduceTitleView, nameTitleView, goalView, introduceView, photoStackView].forEach {
      contentStackView.addArrangedSubview($0)
    }
    
    [photoTitleLabel, photoSelectView].forEach {
      photoStackView.addArrangedSubview($0)
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
    
    photoTitleLabel.snp.makeConstraints {
      $0.height.equalTo(19)
      $0.leading.trailing.equalToSuperview()
    }

    photoSelectView.snp.makeConstraints {
      $0.height.equalTo(100)
      $0.leading.trailing.equalToSuperview()
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
//    viewModel.fetchedMeetingData
//      .withUnretained(self)
//      .subscribe(onNext: { owner, data in
//        owner.setupMeetingData(data: data)
//      })
//      .disposed(by: disposeBag)
    
    introduceTitleView.rx.text.orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.introduceTitleText)
      .disposed(by: disposeBag)
    
    nameTitleView.rx.text.orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.nameTitleText)
      .disposed(by: disposeBag)
    
    goalView.rx.text.orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.goalText)
      .disposed(by: disposeBag)
    
    introduceView.rx.text.orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.introduceText)
      .disposed(by: disposeBag)
    
    viewModel.isBtnEnabled
      .do{print($0)}
      .drive(with: self){ owner, state in
        
      }
      .disposed(by: disposeBag)
//    let input = RecruitPostViewModel.Input(
//      introduceTitleText: introduceTitleView.rx.text.orEmpty.asObservable(),
//      nameTitleText: nameTitleView.rx.text.orEmpty.asObservable(),
//      goalText: goalView.rx.text.orEmpty.asObservable(),
//      introduceText: introduceView.rx.text.orEmpty.asObservable(),
//      meetingImage: photoSelectView.selectedImage.image.
//        
//    )
//            
//    let output = viewModel.transform(input: input)
//    
//    output.isBtnEnabled
//      .distinctUntilChanged()
//      .drive(onNext: { [weak self] in
//        guard let self = self else { return }
//        self.delegate?.checkValidation(
//          index: self.childIndex,
//          state: $0
//        )
//      })
//      .disposed(by: disposeBag)
//    
    tapGesture.rx.event
      .asDriver()
      .drive(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.view.endEditing(true)
      })
      .disposed(by: disposeBag)
    
    scrollView.addGestureRecognizer(tapGesture)
  }
  
  private func setupMeetingData(data: EditMeetingRequest) {
    
  }
}
