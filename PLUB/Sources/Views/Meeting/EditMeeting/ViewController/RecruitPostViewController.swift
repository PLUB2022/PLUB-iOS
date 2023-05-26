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
  
  private let saveButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "저장")
  }
  
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerKeyboardNotification()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeKeyboardNotification()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [scrollView, saveButton].forEach {
      view.addSubview($0)
    }
    
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
    
    saveButton.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(26)
      $0.height.width.equalTo(46)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "모집글 새로 쓰기"
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
        owner.saveButton.isEnabled = state
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
    
    saveButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.viewModel.editMeetingPost()
      }
      .disposed(by: disposeBag)
    
    viewModel.successEditQuestion
      .withUnretained(self)
      .subscribe(onNext: { owner, state in
        owner.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
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

extension RecruitPostViewController {
  func registerKeyboardNotification() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                             name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                             name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  func removeKeyboardNotification() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  func keyboardWillShow(_ sender: Notification) {
    if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      let keyboardHeight: CGFloat = keyboardSize.height
      saveButton.snp.updateConstraints {
        $0.bottom.equalToSuperview().inset(keyboardHeight + 26)
      }
      view.layoutIfNeeded()
    }
  }
  
  @objc
  func keyboardWillHide(_ sender: Notification) {
    saveButton.snp.updateConstraints {
      $0.bottom.equalToSuperview().inset(26)
    }
    view.layoutIfNeeded()
  }
}
