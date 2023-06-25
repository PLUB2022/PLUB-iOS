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

enum WriteBoardType {
  case create // 게시글 작성용
  case modify // 개시글 수정용
}

protocol WriteBoardViewControllerDelegate: AnyObject {
  func whichCreateBoardFeedID(feedID: Int)
}

final class WriteBoardViewController: BaseViewController {
  
  private let viewModel: WriteBoardViewModelType
  private let createBoardType: WriteBoardType
  weak var delegate: WriteBoardViewControllerDelegate?
  
  private var type: PostType = .photo {
    didSet {
      guard type != oldValue else { return }
      changedPostType(type: type)
      changedLayout(type: type)
    }
  }
  
  typealias CompletionHandler = ((String, String?, UIImage?)) -> Void
  private(set) var completionHandler: CompletionHandler?
  
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
    options: [.textCount]
  )
  
  private let tapGesture = UITapGestureRecognizer(
    target: WriteBoardViewController.self,
    action: nil
  )
  
  init(viewModel: WriteBoardViewModelType = WriteBoardViewModel(), plubbingID: Int, createBoardType: WriteBoardType = .create, completionHandler: CompletionHandler? = nil) {
    self.viewModel = viewModel
    self.createBoardType = createBoardType
    self.completionHandler = completionHandler
    super.init(nibName: nil, bundle: nil)
    bind(plubbingID: plubbingID)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    addPhotoImageView.addGestureRecognizer(tapGesture)
    navigationItem.title = title
    if createBoardType == .create {
      photoButton.isSelected = true
    }
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [photoButton, textButton, photoAndTextButton].forEach { buttonStackView.addArrangedSubview($0) }
    
    if createBoardType == .create || type == .photo {
      [photoAddLabel, addPhotoImageView].forEach { boardTypeStackView.addArrangedSubview($0) }
    }
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
        let content = owner.boardContentInputTextView.textView.text
        let feedImage = owner.addPhotoImageView.image
        
        switch owner.createBoardType {
        case .create:
          owner.viewModel.tappedUploadButton.onNext(())
          owner.viewModel.writeTitle.onNext(title)
          switch owner.type {
          case .photo:
            owner.viewModel.whichBoardImage.onNext(feedImage!)
          case .text:
            owner.viewModel.writeContent.onNext(content!)
          case .photoAndText:
            owner.viewModel.writeContent.onNext(content!)
            owner.viewModel.whichBoardImage.onNext(feedImage!)
          }
        case .modify:
          let request: (String, String?, UIImage?)
          switch owner.type {
            case .photo:
              request = (title, nil, feedImage!)
            case .text:
              request = (title, content!, nil)
            case .photoAndText:
              request = (title, content!, feedImage!)
          }
          owner.completionHandler?(request)
        }
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
    
    titleInputTextView.textView.rx.text
      .orEmpty
      .subscribe(viewModel.writeTitle)
      .disposed(by: disposeBag)
    
    boardContentInputTextView.textView.rx.text
      .orEmpty
      .subscribe(viewModel.writeContent)
      .disposed(by: disposeBag)
    
    tapGesture.rx.event
      .subscribe(with: self) { owner, _ in
        let bottomSheet = PhotoBottomSheetViewController()
        bottomSheet.delegate = owner
        owner.present(bottomSheet, animated: true)
      }
      .disposed(by: disposeBag)
    
    viewModel.uploadButtonIsActivated
      .drive(uploadButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    viewModel.whichSuccessCreateBoard
      .emit(with: self){ owner, feedID in
        owner.delegate?.whichCreateBoardFeedID(feedID: feedID)
      }
      .disposed(by: disposeBag)
    
  }
  
  private func changedPostType(type: PostType) {
    uploadButton.isEnabled = false
    viewModel.whichPostType.onNext(type)
  }
  
  private func changedLayout(type: PostType) {
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
  
  func updateForModify(model: BoardModel) {
    guard createBoardType == .modify else { return }
    let type = model.type
    self.type = type
    
    switch type {
    case .photo:
      photoButton.isSelected = true
      titleInputTextView.textView.text = model.title
    case .text:
      textButton.isSelected = true
      titleInputTextView.textView.text = model.title
      boardContentInputTextView.textView.text = model.content
    case .photoAndText:
      photoAndTextButton.isSelected = true
      titleInputTextView.textView.text = model.title
      boardContentInputTextView.textView.text = model.content
      
    }
  }
}

extension WriteBoardViewController: PhotoBottomSheetDelegate {
  func selectImage(image: UIImage) {
    addPhotoImageView.image = image
    viewModel.isSelectImage.onNext(true)
  }
}
