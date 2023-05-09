//
//  RecruitPostViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/10.
//

import UIKit

final class RecruitPostViewController: BaseViewController {
  private let viewModel: RecruitPostViewModel
  weak var delegate: EditMeetingChildViewControllerDelegate?
  
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
  
  private let tapGesture = UITapGestureRecognizer(
    target: RecruitPostViewController.self,
      action: nil
  ).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }

  init(viewModel: RecruitPostViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.fetchMeetingData()
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
      $0.top.equalToSuperview().inset(40)
      $0.leading.trailing.bottom.equalToSuperview()
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
    viewModel.fetchedMeetingData
      .withUnretained(self)
      .subscribe(onNext: { owner, data in
        owner.setupMeetingData(data: data)
      })
      .disposed(by: disposeBag)
    
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
    
    photoSelectView.selectButton.rx.tap
     .asDriver()
      .drive(onNext: {[weak self] in
        guard let self = self else { return }
        let vc = PhotoBottomSheetViewController()
        vc.delegate = self
        self.parent?.present(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    viewModel.isBtnEnabled
      .distinctUntilChanged()
      .drive(with: self){ owner, state in
        self.delegate?.checkValidation(
          index: 0,
          state: state
        )
      }
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
  
  private func setupMeetingData(data: EditMeetingPostRequest) {
    introduceTitleView.setText(text: data.title)
    nameTitleView.setText(text: data.name)
    introduceView.setText(text: data.introduce)
    goalView.setText(text: data.goal)
    guard let image = data.mainImage,
          let imageURL = URL(string: image) else { return }
    photoSelectView.selectedImage.kf.setImage(with: imageURL)
  }
}

extension RecruitPostViewController: PhotoBottomSheetDelegate {
  func selectImage(image: UIImage) {
    photoSelectView.selectedImage.image = image
    let width = photoSelectView.frame.width
    photoSelectView.snp.updateConstraints {
      $0.height.equalTo(width * image.size.height / image.size.width)
    }
    
    viewModel.meetingImage.onNext(image)
  }
}
