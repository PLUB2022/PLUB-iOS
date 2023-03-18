//
//  CreateBoardViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/17.
//

import UIKit

import RxSwift
import SnapKit
import Then

final class CreateBoardViewController: BaseViewController {
  
  private let viewModel: CreateBoardViewModelType
  
  private var type: PostType = .photo {
    didSet {
      guard type != oldValue else { return }
      changedPostType(type: type)
      checkUploadButtonActivated(type: type)
    }
  }
  
  private let boardTypeLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .subtitle
    $0.text = "게시판 타입"
  }
  
  private let buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 8
  }
  
  private let photoButton: UIButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "사진 Only")
    $0.isSelected = true
  }
  
  private let textButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "글 Only")
  }
  
  private let photoAndTextButton: UIButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "사진+글")
  }
  
  private let titleInputTextView = InputTextView(title: "제목", placeHolder: "제목을 입력해주세요")
  
  private let boardTypeStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private let uploadButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "글 업로드")
    $0.isEnabled = false
  }
  
  /// PostType에 따라 필요한 UI
  private lazy var photoAddLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .subtitle
    $0.text = "사진 추가"
  }
  
  private lazy var addPhotoImageView = UIImageView().then {
    $0.backgroundColor = .deepGray
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.isUserInteractionEnabled = true
  }
  
  private lazy var boardContentInputTextView = InputTextView(
    title: "게시할 내용",
    placeHolder: "내용을 입력해주세요",
    totalCharacterLimit: 300
  )
  
  private let tapGesture = UITapGestureRecognizer(
      target: CreateBoardViewController.self,
      action: nil
  )
  
  init(viewModel: CreateBoardViewModelType = CreateBoardViewModel(), plubbingID: Int) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    bind(plubbingID: plubbingID)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(didTappedBackButton))
    addPhotoImageView.addGestureRecognizer(tapGesture)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [photoButton, textButton, photoAndTextButton].forEach { buttonStackView.addArrangedSubview($0) }
    
    [photoAddLabel, addPhotoImageView].forEach { boardTypeStackView.addArrangedSubview($0) }
    [boardTypeLabel, buttonStackView, titleInputTextView, boardTypeStackView, uploadButton].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    boardTypeLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(16)
      $0.leading.equalToSuperview().inset(16)
    }
    
    buttonStackView.snp.makeConstraints {
      $0.top.equalTo(boardTypeLabel.snp.bottom).offset(7.5)
      $0.leading.equalTo(boardTypeLabel)
      $0.trailing.lessThanOrEqualToSuperview()
    }
    
    titleInputTextView.snp.makeConstraints {
      $0.top.equalTo(buttonStackView.snp.bottom).offset(32.5)
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
    }
    
    addPhotoImageView.snp.makeConstraints {
      $0.height.equalTo(245)
    }
    
    boardTypeStackView.snp.makeConstraints {
      $0.top.equalTo(titleInputTextView.snp.bottom).offset(24)
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    uploadButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
      $0.height.equalTo(46)
    }
  }
  
  func bind(plubbingID: Int) {
    super.bind()
    viewModel.selectMeeting.onNext(plubbingID)
    
    photoButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.type = .photo
        owner.photoButton.isSelected = true
        owner.textButton.isSelected = false
        owner.photoAndTextButton.isSelected = false
      }
      .disposed(by: disposeBag)
    
    textButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.type = .text
        owner.photoButton.isSelected = false
        owner.textButton.isSelected = true
        owner.photoAndTextButton.isSelected = false
      }
      .disposed(by: disposeBag)
    
    photoAndTextButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.type = .photoAndText
        owner.photoButton.isSelected = false
        owner.textButton.isSelected = false
        owner.photoAndTextButton.isSelected = true
      }
      .disposed(by: disposeBag)
    
    uploadButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .subscribe(with: self) { owner, _ in
        guard let title = owner.titleInputTextView.textView.text else { return }
        
        let request = BoardsRequest(
          title: title,
          content: owner.boardContentInputTextView.textView.text,
          feedImage: nil
        )
        owner.viewModel.whichUpload.onNext(request)
      }
      .disposed(by: disposeBag)
    
    titleInputTextView.textView.rx.text
      .orEmpty
      .subscribe(with: self) { owner, title in
        owner.viewModel.writeTitle.onNext(title)
      }
      .disposed(by: disposeBag)
    
    boardContentInputTextView.textView.rx.text
      .orEmpty
      .subscribe(with: self) { owner, content in
        owner.viewModel.writeContent.onNext(content)
      }
      .disposed(by: disposeBag)
    
    tapGesture.rx.event
      .subscribe(with: self) { owner, _ in
        let bottomSheet = PhotoBottomSheetViewController()
        bottomSheet.modalPresentationStyle = .overFullScreen
        bottomSheet.delegate = self
        owner.present(bottomSheet, animated: false)
      }
      .disposed(by: disposeBag)
    
    viewModel.isSuccessCreateBoard
      .emit(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
    
    checkUploadButtonActivated(type: .photo)
  }
  
  private func checkUploadButtonActivated(type: PostType) {
    uploadButton.isEnabled = false
    switch type {
    case .photo:
      viewModel.onlyPhotoUploadButtonIsActivated
        .drive(uploadButton.rx.isEnabled)
        .disposed(by: disposeBag)
    case .text:
      viewModel.onlyTextUploadButtonIsActivated
        .drive(uploadButton.rx.isEnabled)
        .disposed(by: disposeBag)
    case .photoAndText:
      viewModel.photoAndTextUploadButtonIsActivated
        .drive(uploadButton.rx.isEnabled)
        .disposed(by: disposeBag)
    }
  }
  
  private func changedPostType(type: PostType) {
    boardTypeStackView.subviews.forEach { $0.removeFromSuperview() }
    switch type {
    case .photo:
      [photoAddLabel, addPhotoImageView].forEach { boardTypeStackView.addArrangedSubview($0) }
      addPhotoImageView.snp.makeConstraints {
        $0.height.equalTo(245)
      }
    case .text:
      boardTypeStackView.addArrangedSubview(boardContentInputTextView)
    case .photoAndText:
      [photoAddLabel, addPhotoImageView, boardContentInputTextView].forEach { boardTypeStackView.addArrangedSubview($0) }
      addPhotoImageView.snp.makeConstraints {
        $0.height.equalTo(245)
      }
      
      boardTypeStackView.setCustomSpacing(24, after: addPhotoImageView)
    }
  }
  
  @objc private func didTappedBackButton() {
    self.navigationController?.popViewController(animated: true)
  }
  
}

extension CreateBoardViewController: PhotoBottomSheetDelegate {
  func selectImage(image: UIImage) {
    addPhotoImageView.image = image
    viewModel.isSelectImage.onNext(true)
  }
}
