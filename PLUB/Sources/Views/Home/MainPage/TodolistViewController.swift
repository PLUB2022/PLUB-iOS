//
//  TodolistViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/02.
//

import UIKit

import SnapKit
import Then

final class TodolistViewController: BaseViewController {
  
  private let viewModel: TodolistViewModelType
  
  private let titleLabel = UILabel().then {
    $0.font = .appFont(family: .nanum, size: 32)
    $0.text = "“2주에 한 권씩”"
    $0.addLineSpacing($0)
  }
  
  private let goalBackgroundView = UIView().then {
    $0.backgroundColor = .subMain
  }
  
  private lazy var todoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 8
  }).then {
    $0.backgroundColor = .background
    $0.register(TodoCollectionViewCell.self, forCellWithReuseIdentifier: TodoCollectionViewCell.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.contentInset = UIEdgeInsets(top: .zero, left: 16, bottom: .zero, right: 16)
  }
  
  init(plubbingID: Int, viewModel: TodolistViewModelType = TodolistViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    bind(plubbindID: plubbingID)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
      $0.centerX.equalToSuperview()
      $0.height.equalTo(40)
    }
    
    todoCollectionView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
  }
  
  func bind(plubbindID: Int) {
    super.bind()
    viewModel.selectPlubbingID.onNext(plubbindID)
  }
}

extension TodolistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodoCollectionViewCell.identifier, for: indexPath) as? TodoCollectionViewCell ?? TodoCollectionViewCell()
    cell.configureUI(with: "")
    cell.delegate = self
    return cell
  }
}

extension TodolistViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return TodoCollectionViewCell.estimatedCommentCellSize(
      CGSize(
        width: view.bounds.width - 32,
        height: 0
      ),
      model: "commentsModelsForSection[indexPath.item]"
    )
  }
}

extension TodolistViewController: TodoCollectionViewCellDelegate {
  func didTappedTodo() {
    let alert = TodoAlertController()
    alert.modalPresentationStyle = .overFullScreen
    present(alert, animated: false)
  }
  
  func didTappedLikeButton(isLiked: Bool) {
    if isLiked {
      /// 해당 투두리스트 좋아요 눌렀을 때
      print("좋아요")
    }
    else {
      /// 해당 투두리스트 좋아요 취소했을 때
      print("좋아요 취소")
    }
  }
  
  func didTappedMoreButton() { /// 투두리스트 작성자에 따른 type 지정해줘야함
    let bottomSheet = TodolistBottomSheetViewController(type: .report)
    bottomSheet.modalPresentationStyle = .overFullScreen
    present(bottomSheet, animated: false)
  }
}
