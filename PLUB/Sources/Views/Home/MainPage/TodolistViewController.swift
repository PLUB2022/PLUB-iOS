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
  func didTappedTodoPlanner(date: Date)
}

final class TodolistViewController: BaseViewController {
  
  private let viewModel: TodolistViewModelType
  weak var delegate: TodolistDelegate?
  
  private let plubbingID: Int
  private let goal: String
  
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
  
  private lazy var todoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 8
    $0.scrollDirection = .vertical
  }).then {
    $0.backgroundColor = .background
    $0.register(TodoCollectionViewCell.self, forCellWithReuseIdentifier: TodoCollectionViewCell.identifier)
    $0.register(TodoCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TodoCollectionHeaderView.identifier)
    $0.register(TodoGoalHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TodoGoalHeaderView.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.contentInset = UIEdgeInsets(top: .zero, left: 16, bottom: .zero, right: 16)
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
  }
  
  init(plubbingID: Int, goal: String, viewModel: TodolistViewModelType = TodolistViewModel()) {
    self.viewModel = viewModel
    self.plubbingID = plubbingID
    self.goal = goal
    super.init(nibName: nil, bundle: nil)
    bind(plubbingID: plubbingID)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.clearStatus()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(todoCollectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    todoCollectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
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
    return model.count + 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if section == 0 {
      return 0
    }
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if indexPath.section == 0 {
      return UICollectionViewCell()
    }
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodoCollectionViewCell.identifier, for: indexPath) as? TodoCollectionViewCell ?? TodoCollectionViewCell()
    cell.configureUI(with: model[indexPath.section - 1].cellModel)
    cell.delegate = self
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if indexPath.section == 0 {
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TodoGoalHeaderView.identifier, for: indexPath) as? TodoGoalHeaderView ?? TodoGoalHeaderView()
      header.configureUI(with: goal)
      return header
    }
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TodoCollectionHeaderView.identifier, for: indexPath) as? TodoCollectionHeaderView ?? TodoCollectionHeaderView()
    header.configureUI(with: model[indexPath.section - 1].headerModel)
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if section == 0 {
      return CGSize(width: collectionView.frame.width, height: 85)
    }
    let width: CGFloat = collectionView.frame.width
    let height: CGFloat = 8 + 21 + 8
    return CGSize(width: width, height: height)
  }
}

extension TodolistViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if indexPath.section == 0 {
      return .zero
    }
    return TodoCollectionViewCell.estimatedCommentCellSize(
      CGSize(
        width: view.bounds.width - 32,
        height: UIView.layoutFittingCompressedSize.height
      ),
      model: model[indexPath.section - 1].cellModel
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
  
  func didTappedMoreButton(isAuthor: Bool, date: String) { /// 투두리스트 작성자에 따른 type 지정해줘야함
    guard let date = DateFormatterFactory.dateWithHypen.date(from: date) else {
      return
    }
    
    let bottomSheet = isAuthor ? TodolistBottomSheetViewController(type: .todoPlanner(date)) : TodolistBottomSheetViewController(type: .report)
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
  func didTappedTodoPlanner(date: Date) {
    delegate?.didTappedTodoPlanner(date: date)
  }
  
  func didTappedReport() {
    Log.debug("투두리스트 바텀시트 신고 클릭")
  }
}
