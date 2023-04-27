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
    $0.backgroundColor = .background
  }
  
  // MARK: Comment Posting View (댓글 작성 UI)
  
  /// 답글을 달거나 댓글을 수정할 때 보여지는 데코레이터 뷰
  private let decoratorView = CommentOptionDecoratorView().then {
    $0.backgroundColor = .background
    $0.isHidden = true
  }
  
  private let commentInputView = CommentInputView().then {
    $0.backgroundColor = .background
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
    [collectionView, commentInputView, decoratorView].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    collectionView.snp.makeConstraints {
      $0.directionalHorizontalEdges.top.equalTo(view.safeAreaLayoutGuide)
      $0.bottom.equalTo(commentInputView.snp.top)
    }
    
    commentInputView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalTo(view.safeAreaLayoutGuide)
      $0.bottom.equalTo(view.safeAreaLayoutGuide)
    }
    
    decoratorView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalTo(view.safeAreaLayoutGuide)
      $0.bottom.equalTo(commentInputView.snp.top)
      $0.height.equalTo(28)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    // == gesture ==
    panGesture.delegate = self
    collectionView.addGestureRecognizer(tapGesture)
    collectionView.addGestureRecognizer(panGesture)
    
    // == comment posting delegate ==
    commentInputView.delegate = self
    decoratorView.delegate = self
  }
  
  override func bind() {
    super.bind()
    collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    
    viewModel.decoratorNameObserable
      .subscribe(with: self) { owner, tuple in
        owner.decoratorView.labelText = tuple.labelText
        owner.decoratorView.buttonText = tuple.buttonText
        owner.decoratorView.isHidden = false
      }
      .disposed(by: disposeBag)
    
    viewModel.showBottomSheetObservable
      .subscribe(with: self) { owner, tuple in
        let bottomSheetVC = CommentOptionBottomSheetViewController(commentID: tuple.commentID, userAccessType: tuple.userType).then {
          $0.delegate = owner
        }
        owner.present(bottomSheetVC, animated: true)
      }
      .disposed(by: disposeBag)
    
    viewModel.editCommentTextObservable
      .bind(to: commentInputView.rx.commentText)
      .disposed(by: disposeBag)
    
    // ViewModel에게 `DiffableDataSource`처리를 해주기 위해 collectionView를 전달
    viewModel.setCollectionViewObserver.onNext(collectionView)
    
    // 페이징 처리 - 현재 사용자가 바로보고있는 Offset의 y값과 실제 CollectionView의 높이값을 전달
    collectionView.rx.contentOffset
      .compactMap { [weak self] offset in
        guard let self else { return nil }
        return (self.collectionView.contentSize.height, offset.y)
      }
      .bind(to: viewModel.offsetObserver)
      .disposed(by: disposeBag)
    
    // collectionView가 터치되면 first responder를 resign 시킴
    tapGesture.rx.event
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.commentInputView.endEditing(true)
      }
      .disposed(by: disposeBag)
    
    // collectionView에서 아래로 스와이프되었을 때 first responder를 resign 시킴
    panGesture.rx.event
      .asDriver()
      .map { [weak self] in $0.translation(in: self?.collectionView) }
      .filter { $0.y > 60 } // 특정 threshold값만큼 아래로 스와이프 하면 emit하도록 설정, threshold: 60
      .drive(with: self) { owner, _ in
        owner.commentInputView.endEditing(true)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - CommentInputViewDelegate

extension BoardDetailViewController: CommentInputViewDelegate {
  func commentInputView(_ textView: UITextView, writtenText: String) {
    textView.text = ""
    viewModel.commentsInput.onNext(writtenText)
    decoratorView.isHidden = true
  }
}

// MARK: - CommentOptionViewDelegate

extension BoardDetailViewController: CommentOptionViewDelegate {
  func cancelButtonTapped() {
    viewModel.commentOptionObserver.onNext(.commentOrReply)
    viewModel.targetIDObserver.onNext(nil)
    decoratorView.isHidden = true
  }
}

// MARK: - CommentOptionBottomSheetDelegate

extension BoardDetailViewController: CommentOptionBottomSheetDelegate {
  func deleteButtonTapped(commentID: Int) {
    viewModel.deleteIDObserver.onNext(commentID)
  }
  
  func editButtonTapped(commentID: Int) {
    // 순서 중요
    viewModel.targetIDObserver.onNext(commentID)
    viewModel.commentOptionObserver.onNext(.edit)
  }
  
  func reportButtonTapped(commentID: Int) {
    print(#function)
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
    let groupID = Set(viewModel.comments.map(\.groupID)).sorted()[indexPath.section - 1]
    let commentsModelsForSection = viewModel.comments
      .filter { $0.groupID == groupID }
      .sorted { $0.commentID < $1.commentID }
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
    
    self.commentInputView.snp.updateConstraints {
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(keyboardHeight)
    }
    
    UIView.animate(withDuration: 1) {
      self.view.layoutIfNeeded()
    }
  }
  
  @objc
  func keyboardWillHide(_ sender: Notification) {
    commentInputView.snp.updateConstraints {
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
