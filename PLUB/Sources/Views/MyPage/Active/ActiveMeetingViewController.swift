//
//  ActiveMeetingViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/27.
//

import UIKit

final class ActiveMeetingViewController: BaseViewController {
  private let viewModel: ActiveMeetingViewModelType
  private let recruitingHeaderView = RecruitingHeaderView()
    
  private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
    $0.separatorStyle = .none
    $0.showsVerticalScrollIndicator = false
    $0.backgroundColor = .background
    $0.delegate = self
    $0.dataSource = self
    $0.tableHeaderView = recruitingHeaderView
    $0.tableHeaderView?.frame.size.height = 114
    $0.register(MyTodoTableViewCell.self, forCellReuseIdentifier: MyTodoTableViewCell.identifier)
    $0.register(MyFeedTableViewCell.self, forCellReuseIdentifier: MyFeedTableViewCell.identifier)
    $0.register(NoActivityTableViewCell.self, forCellReuseIdentifier: NoActivityTableViewCell.identifier)
    $0.register(MyTodoSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: MyTodoSectionHeaderView.identifier)
  }
  
  private let recruitButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "모집글 바로가기")
    $0.layer.cornerRadius = 16
    $0.layer.masksToBounds = true
  }
  
  init(viewModel: ActiveMeetingViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  override func setupLayouts() {
    super.setupLayouts()
    [tableView, recruitButton].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    tableView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    recruitButton.snp.makeConstraints {
      $0.height.equalTo(32)
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(24)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
    viewModel.meetingInfoDriver
      .drive(with: self) { owner, myInfo in
        owner.recruitingHeaderView.setupData(with: myInfo, type: .active)
      }
      .disposed(by: disposeBag)
    
    viewModel.reloadTaleViewDriver
      .drive(with: self) { owner, myInfo in
        owner.tableView.reloadData()
      }
      .disposed(by: disposeBag)
    
    recruitButton
      .rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        let vc = DetailRecruitmentViewController(plubbingID: owner.viewModel.plubbingID)
        owner.navigationController?.pushViewController(vc, animated: true)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - UITableViewDelegate

extension ActiveMeetingViewController: UITableViewDelegate {
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
    headerView.delegate = self
    switch MyActivityType.allCases[section] {
    case .todo: headerView.setupData(type: .todo, isViewAll: !viewModel.todoList.isEmpty)
    case .feed: headerView.setupData(type: .feed, isViewAll: !viewModel.feedList.isEmpty)
    }

    return headerView
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .zero
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch MyActivityType.allCases[indexPath.section] {
    case .todo:
      guard !viewModel.todoList.isEmpty else { return }
      //TODO: 수빈 자세히보기 페이지 이동 코드 추가
    case .feed:
      guard !viewModel.feedList.isEmpty else { return }
      let feed = viewModel.feedList[indexPath.row]
      let vc = BoardDetailViewController(
        viewModel: BoardDetailViewModelWithFeedsFactory.make(plubbingID: viewModel.plubbingID, feedID: feed.feedID)
      )
      vc.title = recruitingHeaderView.getPlubbingTitle()
      navigationController?.pushViewController(vc, animated: true)
    }
  }
}

// MARK: - UITableViewDataSource

extension ActiveMeetingViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return MyActivityType.allCases.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch MyActivityType.allCases[indexPath.section] {
    case .todo:
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
      
    case .feed:
      if viewModel.feedList.isEmpty {
        guard let cell = tableView.dequeueReusableCell(
          withIdentifier: NoActivityTableViewCell.identifier,
          for: indexPath
        ) as? NoActivityTableViewCell else { return UITableViewCell() }

        cell.setupData(type: .feed)
        
        return cell
      } else {
        let feed = viewModel.feedList[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(
          withIdentifier: MyFeedTableViewCell.identifier,
          for: indexPath
        ) as? MyFeedTableViewCell else { return UITableViewCell() }

        cell.configure(with: feed.toBoardModel)

        return cell
      }
    }
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch MyActivityType.allCases[section] {
    case .todo:
      let todoCount = viewModel.todoList.count
      return todoCount == 0 ? 1 : todoCount
    case .feed:
      let feedCount = viewModel.feedList.count
      return feedCount == 0 ? 1 : feedCount
    }
  }
}

extension ActiveMeetingViewController: MyTodoSectionHeaderViewDelegate {
  func moreButtonTapped(type: MyActivityType) {
    switch type {
    case .todo:
      let vc = MyTodoViewController(
        viewModel:
          MyTodoViewModel(
            plubbingID: viewModel.plubbingID,
            plubbingTitle: recruitingHeaderView.getPlubbingTitle(),
            inquireMyTodoUseCase: DefaultInquireMyTodoUseCase()
          )
      )
      navigationController?.pushViewController(vc, animated: true)
    case .feed:
      let vc = MyFeedViewController(
      viewModel:
        MyFeedViewModel(
          plubbingID: viewModel.plubbingID,
          plubbingTitle: recruitingHeaderView.getPlubbingTitle(),
          inquireMyFeedUseCase: DefaultInquireMyFeedUseCase()
        )
    )
    navigationController?.pushViewController(vc, animated: true)
    }
  }
}

extension ActiveMeetingViewController: MyTodoTableViewCellDelegate {
  func didTappedLikeButton(timelineID: Int) {
    viewModel.selectLikeButton.onNext(timelineID)
  }
  
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


extension ActiveMeetingViewController: TodoAlertDelegate {
  func whichProofImage(image: UIImage) {
    viewModel.whichProofImage.onNext(image)
  }
}
