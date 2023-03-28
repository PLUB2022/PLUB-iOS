// 
//  BoardDetailViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/03/06.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class BoardDetailViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let viewModel: BoardDetailViewModelType & BoardDetailDataStore
  
  /// 터치 및 아래로 스와이프를 인식하기 위한 gesture recognizer
  private let panGesture = UIPanGestureRecognizer(target: BoardDetailViewController.self, action: nil)
  private let tapGesture = UITapGestureRecognizer(target: BoardDetailViewController.self, action: nil)
  
  // MARK: - UI Components
  
  private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
    $0.register(BoardDetailCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BoardDetailCollectionHeaderView.identifier)
    $0.register(BoardDetailCollectionViewCell.self, forCellWithReuseIdentifier: BoardDetailCollectionViewCell.identifier)
    $0.backgroundColor = .background
  }
  
  // MARK: Comment Posting View (댓글 작성 UI)
  
  private let commentContainerView = UIView()
  
  private let separatorLineView = UIView().then {
    $0.backgroundColor = .lightGray
  }
  
  private let commentPostingStackView = UIStackView().then {
    $0.spacing = 8
    $0.alignment = .top
  }
  
  private let profileImageView = UIImageView(image: .init(named: "userDefaultImage")).then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let commentPostingInputView = CommentInputView().then {
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 8
    $0.backgroundColor = .white
  }
  
  // MARK: - Initializations
  
  init(viewModel: BoardDetailViewModelType & BoardDetailDataStore) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  
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
    [collectionView, commentContainerView].forEach {
      view.addSubview($0)
    }
    
    [commentPostingStackView, separatorLineView].forEach {
      commentContainerView.addSubview($0)
    }
    
    [profileImageView, commentPostingInputView].forEach {
      commentPostingStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    collectionView.snp.makeConstraints {
      $0.directionalHorizontalEdges.top.equalTo(view.safeAreaLayoutGuide)
      $0.bottom.equalTo(commentContainerView.snp.top)
    }
    
    commentContainerView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalTo(view.safeAreaLayoutGuide)
      $0.bottom.equalTo(view.safeAreaLayoutGuide)
    }
    
    commentPostingStackView.snp.makeConstraints {
      $0.directionalVerticalEdges.equalToSuperview().inset(Metric.commentPostingStackViewVerticalInset)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Metric.commentPostingStackViewHorizontalInset)
    }
    
    profileImageView.snp.makeConstraints {
      $0.size.equalTo(Metric.profileImageViewSize)
    }
    
    separatorLineView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(Metric.separatorLineHeight)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    // == gesture ==
    panGesture.delegate = self
    collectionView.addGestureRecognizer(tapGesture)
    collectionView.addGestureRecognizer(panGesture)
    
    // == comment posting delegate ==
    commentPostingInputView.delegate = self
  }
  
  override func bind() {
    super.bind()
    collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    
    // ViewModel에게 `DiffableDataSource`처리를 해주기 위해 collectionView를 전달
    viewModel.setCollectionViewObserver.onNext(collectionView)
    
    // collectionView가 터치되면 first responder를 resign 시킴
    tapGesture.rx.event
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.commentPostingInputView.endEditing(true)
      }
      .disposed(by: disposeBag)
    
    // collectionView에서 아래로 스와이프되었을 때 first responder를 resign 시킴
    panGesture.rx.event
      .asDriver()
      .map { [weak self] in $0.translation(in: self?.collectionView) }
      .filter { $0.y > 60 } // 특정 threshold값만큼 아래로 스와이프 하면 emit하도록 설정, threshold: 60
      .drive(with: self) { owner, _ in
        owner.commentPostingInputView.endEditing(true)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - CommentInputViewDelegate

extension BoardDetailViewController: CommentInputViewDelegate {
  func commentInputView(_ textView: UITextView, writtenText: String) {
    textView.text = ""
    viewModel.commentsInput.onNext(writtenText)
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension BoardDetailViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    // * section은 1부터 시작, section 순서는 groupID 순과 동일함
    // * viewModel의 `comments`는 section, item과 상관없이 일차원 배열로 나열되어있음
    // * 위 배열에서 section과 item의 맞는 모델을 찾아 사이즈를 구해야함
    // * 따라서 section값에 따른 groupID를 먼저 구하고, groupID가 동일한 배열만을 빼냄
    // * 빼낸 배열은 item을 인덱스로하여 모델을 가져오도록 구현
    let groupID = Array(Set(viewModel.comments.map { $0.groupID })).sorted()[indexPath.section - 1]
    let commentsModelsForSection = viewModel.comments.filter { $0.groupID == groupID }
    let size = BoardDetailCollectionViewCell.estimatedCommentCellSize(CGSize(width: view.bounds.width, height: 0), commentContent: commentsModelsForSection[indexPath.item])
    return size
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    // 첫 번째 section에만 게시글이 보이도록 설정
    guard section == 0 else { return .zero }
    // 동적 높이 처리
    let headerRegistration = BoardDetailViewModel.HeaderRegistration(elementKind: UICollectionView.elementKindSectionHeader) { [viewModel] supplementaryView, elementKind, indexPath in
      supplementaryView.configure(with: viewModel.content)
    }
    let indexPath = IndexPath(row: 0, section: section)
    let headerView = collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
    return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
  }
}

// MARK: - Keyboards

private extension BoardDetailViewController {
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
    guard let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
      return
    }
    
    let keyboardHeight = keyboardSize.height
    
    self.commentContainerView.snp.updateConstraints {
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(keyboardHeight)
    }
    
    UIView.animate(withDuration: 1) {
      self.view.layoutIfNeeded()
    }
  }
  
  @objc
  func keyboardWillHide(_ sender: Notification) {
    commentContainerView.snp.updateConstraints {
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
    }
    
    UIView.animate(withDuration: 1) {
      self.view.layoutIfNeeded()
    }
  }
}

// MARK: - UIGestureRecognizerDelegate

extension BoardDetailViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // navigation back gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}

// MARK: - Constants

private extension BoardDetailViewController {
  
  enum Metric {
    static let commentPostingStackViewHeight = 54
    static let commentPostingStackViewHorizontalInset = 16
    static let commentPostingStackViewVerticalInset = 8
    static let profileImageViewSize = 32
    static let commentPostingTextFieldHeight = 32
    static let separatorLineHeight = 1
  }
  
  enum Constants {
    static let placeholder = "댓글을 입력하세요"
  }
}
