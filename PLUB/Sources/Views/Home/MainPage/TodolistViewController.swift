//
//  TodolistViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/02.
//

import UIKit

import RxSwift
import SnapKit
import Then

struct TodolistModel {
  let headerModel: TodoCollectionHeaderViewModel
  var cellModel: TodoCollectionViewCellModel
}

protocol TodolistDelegate: AnyObject {
  func didTappedTodoPlanner()
}

final class TodolistViewController: BaseViewController {
  
  private let viewModel: TodolistViewModelType
  weak var delegate: TodolistDelegate?
  
  private let plubbingID: Int
  
  private var model: [TodolistModel] = [] {
    didSet {
      todoCollectionView.reloadData()
    }
  }
  
  private var headerModel: [TodoCollectionHeaderViewModel] = [] {
    didSet {
      todoCollectionView.reloadData()
    }
  }
  
  private let scrollView = UIScrollView().then {
    $0.showsVerticalScrollIndicator = true
    $0.showsHorizontalScrollIndicator = false
    $0.isScrollEnabled = true
    $0.alwaysBounceVertical = true
  }
  
  private let scrollContainerView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .appFont(family: .nanum, size: 32)
    $0.textAlignment = .center
    $0.numberOfLines = 0
    $0.sizeToFit()
  }
  
  private let goalBackgroundView = UIView().then {
    $0.backgroundColor = .subMain
  }
  
  private lazy var todoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 8
  }).then {
    $0.backgroundColor = .background
    $0.register(TodoCollectionViewCell.self, forCellWithReuseIdentifier: TodoCollectionViewCell.identifier)
    $0.register(TodoCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TodoCollectionHeaderView.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.contentInset = UIEdgeInsets(top: .zero, left: 16, bottom: .zero, right: 16)
    $0.isScrollEnabled = false
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
  }
  
  init(plubbingID: Int, goal: String, viewModel: TodolistViewModelType = TodolistViewModel()) {
    self.viewModel = viewModel
    self.plubbingID = plubbingID
    titleLabel.text = goal
    super.init(nibName: nil, bundle: nil)
    bind(plubbingID: plubbingID)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.clearStatus()
    viewModel.selectPlubbingID.onNext(plubbingID)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(scrollContainerView)
    [goalBackgroundView, titleLabel, todoCollectionView].forEach { scrollContainerView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    scrollContainerView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    goalBackgroundView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(40)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(187)
      $0.height.equalTo(19)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(24)
      $0.directionalHorizontalEdges.equalToSuperview()
    }
    
    todoCollectionView.snp.makeConstraints {
      $0.top.equalTo(goalBackgroundView.snp.bottom).offset(26)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
      $0.height.equalTo(UIScreen.main.bounds.height - Device.navigationBarHeight - 32 - 24 - 21 - 40)
    }
  }
  
  func bind(plubbingID: Int) {
    super.bind()
    viewModel.selectPlubbingID.onNext(plubbingID)
    
    viewModel.todoTimelineModel
      .drive(rx.model)
      .disposed(by: disposeBag)
    
    viewModel.successCompleteTodolist
      .emit(onNext: { success in
        Log.debug("투두완료성공 \(success)")
      })
      .disposed(by: disposeBag)
    
    viewModel.successProofTodolist
      .emit(with: self) { owner, image in
        let alert = ProofTodoAlertViewController()
        alert.modalPresentationStyle = .overFullScreen
        owner.present(alert, animated: false)
      }
      .disposed(by: disposeBag)
    
    todoCollectionView.rx.didScroll
      .subscribe(with: self) { owner, _ in
        let offSetY = owner.todoCollectionView.contentOffset.y
        let contentHeight = owner.todoCollectionView.contentSize.height
        
        if offSetY > (contentHeight - owner.todoCollectionView.frame.size.height) {
          owner.viewModel.fetchMoreDatas.onNext(())
        }
      }
      .disposed(by: disposeBag)
  
  }
}

extension TodolistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return model.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodoCollectionViewCell.identifier, for: indexPath) as? TodoCollectionViewCell ?? TodoCollectionViewCell()
    cell.configureUI(with: model[indexPath.section].cellModel)
    cell.delegate = self
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TodoCollectionHeaderView.identifier, for: indexPath) as? TodoCollectionHeaderView ?? TodoCollectionHeaderView()
    header.configureUI(with: model[indexPath.section].headerModel)
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    let width: CGFloat = collectionView.frame.width
    let height: CGFloat = 8 + 21 + 8
    return CGSize(width: width, height: height)
  }
}

extension TodolistViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return TodoCollectionViewCell.estimatedCommentCellSize(
      CGSize(
        width: view.bounds.width - 32,
        height: UIView.layoutFittingCompressedSize.height
      ),
      model: model[indexPath.section].cellModel
    )
  }
}

extension TodolistViewController: TodoCollectionViewCellDelegate {
  func didTappedTodo(todoID: Int, isCompleted: Bool, model: TodoAlertModel) {
    viewModel.selectTodolistID.onNext(todoID)
    viewModel.selectComplete.onNext(isCompleted)
    
    if isCompleted {
      let alert = TodoAlertController()
      alert.modalPresentationStyle = .overFullScreen
      alert.delegate = self
      alert.configureUI(with: model)
      present(alert, animated: false)
    }
  }
  
  func didTappedLikeButton(timelineID: Int) {
    viewModel.selectLikeButton.onNext(timelineID)
  }
  
  func didTappedMoreButton(isAuthor: Bool) { /// 투두리스트 작성자에 따른 type 지정해줘야함
    ///
    let bottomSheet = isAuthor ? TodolistBottomSheetViewController(type: .todoPlanner) : TodolistBottomSheetViewController(type: .report)
    bottomSheet.delegate = self
    present(bottomSheet, animated: true)
  }
}

extension TodolistViewController: TodoAlertDelegate {
  func whichProofImage(image: UIImage) {
    viewModel.whichProofImage.onNext(image)
  }
}

extension TodolistViewController: TodolistBottomSheetDelegate {
  func didTappedTodoPlanner() {
    delegate?.didTappedTodoPlanner()
  }
  
  func didTappedReport() {
    Log.debug("투두리스트 바텀시트 신고 클릭")
  }
}
