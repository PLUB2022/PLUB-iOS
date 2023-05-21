//
//  MyTodoViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/05/14.
//

import UIKit

import SnapKit
import RxSwift

final class MyTodoViewController: BaseViewController {
  private let viewModel: MyTodoViewModelType
  
  private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
    $0.separatorStyle = .none
    $0.showsVerticalScrollIndicator = false
    $0.backgroundColor = .background
    $0.delegate = self
    $0.dataSource = self
    $0.register(MyTodoTableViewCell.self, forCellReuseIdentifier: MyTodoTableViewCell.identifier)
    $0.register(NoActivityTableViewCell.self, forCellReuseIdentifier: NoActivityTableViewCell.identifier)
    $0.register(MyTodoSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: MyTodoSectionHeaderView.identifier)
  }
  
  init(viewModel: MyTodoViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(tableView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    tableView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
    
    tableView
      .rx.contentOffset
      .compactMap { [tableView] offset in
        return (tableView.contentSize.height, offset.y)
      }
      .bind(to: viewModel.offsetObserver)
      .disposed(by: disposeBag)
    
    viewModel.reloadTaleViewDriver
      .drive(with: self) { owner, myInfo in
        owner.tableView.reloadData()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - UITableViewDelegate

extension MyTodoViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyTodoSectionHeaderView.identifier) as? MyTodoSectionHeaderView else {
        return UIView()
    }

    headerView.setupData(type: .todo, isViewAll: false, isDetail: true)
    return headerView
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .zero
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

  }
}

// MARK: - UITableViewDataSource

extension MyTodoViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if viewModel.todoList.isEmpty {
      guard let cell = tableView.dequeueReusableCell(
        withIdentifier: NoActivityTableViewCell.identifier,
        for: indexPath
      ) as? NoActivityTableViewCell else { return UITableViewCell() }

      cell.setupData(type: .todo)

      return cell
    } else {
      let todo = viewModel.todoList[indexPath.row]
      guard let cell = tableView.dequeueReusableCell(
        withIdentifier: MyTodoTableViewCell.identifier,
        for: indexPath
      ) as? MyTodoTableViewCell else { return UITableViewCell() }

      cell.setupData(with: todo)
      cell.delegate = self
      
      return cell
    }
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      let todoCount = viewModel.todoList.count
      return todoCount == 0 ? 1 : todoCount
  }
}

extension MyTodoViewController: MyTodoTableViewCellDelegate {
  func didTappedCheckButton(todo: Todo) {
    if todo.isProof { return } // 이미 인증된 TODO는 체크 해제 불가
    
    viewModel.selectTodolistID.onNext(todo.todoID)
    viewModel.selectComplete.onNext(!todo.isChecked)
    
    if !todo.isChecked {
      let alert = TodoAlertController()
      alert.modalPresentationStyle = .overFullScreen
      alert.delegate = self
      alert.configureUI(with: todo.toTodoAlertModel)
      present(alert, animated: false)
    }
  }
}


extension MyTodoViewController: TodoAlertDelegate {
  func whichProofImage(image: UIImage) {
    viewModel.whichProofImage.onNext(image)
  }
}
