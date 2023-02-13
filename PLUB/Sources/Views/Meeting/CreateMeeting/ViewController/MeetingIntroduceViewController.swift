//
//  MeetingIntroduceViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/15.
//

import UIKit

import RxSwift
import SnapKit

final class MeetingIntroduceViewController: BaseViewController {
  
  // MARK: - Property
  private var viewModel: MeetingIntroduceViewModel
  weak var delegate: CreateMeetingChildViewControllerDelegate?
  private var childIndex: Int
  
  private let scrollView = UIScrollView().then {
    $0.bounces = false
    $0.showsVerticalScrollIndicator = false
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 48
  }
  
  private let titleView = CreateMeetingTitleView(
    title: "우리 모임은 어떤 모임인가요?",
    description: "모임에 대해서 자세하게 설명해주세요."
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
  
  private let tapGesture = UITapGestureRecognizer(
    target: MeetingIntroduceViewController.self,
      action: nil
  ).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  init(
    viewModel: MeetingIntroduceViewModel,
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
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(contentStackView)
    
    [titleView, goalView, introduceView, photoStackView].forEach {
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
      $0.directionalEdges.equalToSuperview()
      $0.width.equalTo(scrollView.snp.width)
    }
    
    contentStackView.setCustomSpacing(56, after: introduceView)
    
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
    
    let input = MeetingIntroduceViewModel.Input(
      goalText: goalView.textView.rx.text.orEmpty.asObservable(),
      introduceText: introduceView.textView.rx.text.orEmpty.asObservable()
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
    
    photoSelectView.selectButton.rx.tap
     .asDriver()
      .drive(onNext: {[weak self] in
        guard let self = self else { return }
        let vc = PhotoBottomSheetViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        self.parent?.present(vc, animated: false)
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

extension MeetingIntroduceViewController: PhotoBottomSheetDelegate {
  func selectImage(image: UIImage) {
    photoSelectView.selectedImage.image = image
    let width = photoSelectView.frame.width
    photoSelectView.snp.updateConstraints {
      $0.height.equalTo(width * image.size.height / image.size.width)
    }
    
    viewModel.imageInputRelay.accept(image)
  }
}
