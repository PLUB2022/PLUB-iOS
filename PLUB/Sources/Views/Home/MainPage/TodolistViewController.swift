//
//  TodolistViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/02.
//

import UIKit

import SnapKit
import Then

struct TodolistModel {
  let headerModel: TodoCollectionHeaderViewModel
  let cellModel: TodoCollectionViewCellModel
}

final class TodolistViewController: BaseViewController {
  
  private let viewModel: TodolistViewModelType
  
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
  
  private let titleLabel = UILabel().then {
    $0.font = .appFont(family: .nanum, size: 32)
    $0.text = "“2주에 한 권씩”"
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
  }
  
  init(plubbingID: Int, viewModel: TodolistViewModelType = TodolistViewModel()) {
    self.viewModel = viewModel
    self.plubbingID = plubbingID
    super.init(nibName: nil, bundle: nil)
    bind(plubbingID: plubbingID)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.selectPlubbingID.onNext(plubbingID)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [goalBackgroundView, titleLabel, todoCollectionView].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    goalBackgroundView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(32)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(187)
      $0.height.equalTo(19)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(16)
      $0.directionalHorizontalEdges.equalToSuperview()
    }
    
    todoCollectionView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
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
        print("성공했니 \(success)")
      })
      .disposed(by: disposeBag)
  
  }
}

extension TodolistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return model.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return model.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodoCollectionViewCell.identifier, for: indexPath) as? TodoCollectionViewCell ?? TodoCollectionViewCell()
    cell.configureUI(with: model[indexPath.row].cellModel)
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
      model: model[indexPath.row].cellModel
    )
  }
}

extension TodolistViewController: TodoCollectionViewCellDelegate {
  func didTappedTodo(todoID: Int, isCompleted: Bool) {
    viewModel.selectTodolistID.onNext(todoID)
    viewModel.selectComplete.onNext(isCompleted)
    if isCompleted {
      let alert = TodoAlertController()
      alert.modalPresentationStyle = .overFullScreen
      present(alert, animated: false)
    }
  }
  
  func didTappedLikeButton(timelineID: Int) {
    viewModel.selectLikeButton.onNext(timelineID)
  }
  
  func didTappedMoreButton() { /// 투두리스트 작성자에 따른 type 지정해줘야함
    let bottomSheet = TodolistBottomSheetViewController(type: .report)
    present(bottomSheet, animated: true)
  }
}
