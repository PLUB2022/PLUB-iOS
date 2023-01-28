//
//  MeetingQuestionViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/09.
//

import UIKit

import RxSwift
import RxCocoa

enum MeetingQuestionSectionType: Int, CaseIterable {
  case questionSection = 0
  case addQuestionSection = 1
  
  var index: Int {
    return self.rawValue
  }
  
  var height: CGFloat {
    switch self {
    case .questionSection, .addQuestionSection:
      return UITableView.automaticDimension
    }
  }
}

final class MeetingQuestionViewController: BaseViewController {
  
  private var viewModel: MeetingQuestionViewModel
  weak var delegate: CreateMeetingChildViewControllerDelegate?
  private var childIndex: Int
  
  private lazy var questionHeaderView = QuestionHeaderView().then {
    $0.delegate = self
  }
  
  private lazy var tableView = UITableView(frame: CGRect.zero, style: .grouped).then {
    $0.separatorStyle = .none
    $0.showsVerticalScrollIndicator = false
    $0.backgroundColor = .background
    $0.delegate = self
    $0.dataSource = self
    $0.tableHeaderView = questionHeaderView
    $0.tableHeaderView?.frame.size.height = 212
    $0.register(QuestionTableViewCell.self, forCellReuseIdentifier: QuestionTableViewCell.identifier)
    $0.register(AddQuestionTableViewCell.self, forCellReuseIdentifier: AddQuestionTableViewCell.identifier)
  }
  
  init(
    viewModel: MeetingQuestionViewModel,
    childIndex: Int
  ) {
    self.viewModel = viewModel
    self.childIndex = childIndex
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
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
    viewModel.allQuestionFilled
      .subscribe(onNext: { state in
        self.hideAddQuestionButton(state: !(state && self.viewModel.questionList.count < 5))
      })
      .disposed(by: disposeBag)
    
    Observable.combineLatest(
      viewModel.allQuestionFilled,
      viewModel.noQuestionMode
    )
      .subscribe(onNext: { tuple in
        self.delegate?.checkValidation(
          index: self.childIndex,
          state: tuple.0 || tuple.1
        )
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - UITableViewDelegate

extension MeetingQuestionViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}

// MARK: - UITableViewDataSource

extension MeetingQuestionViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return MeetingQuestionSectionType.allCases.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case MeetingQuestionSectionType.questionSection.index:
      guard let cell = tableView.dequeueReusableCell(
        withIdentifier: QuestionTableViewCell.identifier,
        for: indexPath
      ) as? QuestionTableViewCell else { return UITableViewCell() }
      
      cell.indexPathRow = indexPath.row
      cell.setCellData(text: viewModel.questionList[indexPath.row])
      cell.delegate = self
      
      return cell
      
    case MeetingQuestionSectionType.addQuestionSection.index:
      guard let cell = tableView.dequeueReusableCell(
        withIdentifier: AddQuestionTableViewCell.identifier,
        for: indexPath
      ) as? AddQuestionTableViewCell else { return UITableViewCell() }
      
      cell.delegate = self
      
      return cell
      
    default:
      return UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return UIView()
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let noQuestionMode = viewModel.noQuestionMode.value
    switch section {
    case MeetingQuestionSectionType.questionSection.index:
      return noQuestionMode ? 0 : viewModel.questionList.count
    case MeetingQuestionSectionType.addQuestionSection.index:
      return noQuestionMode ? 0 : 1
    default:
      return 0
    }
  }
}

extension MeetingQuestionViewController: QuestionTableViewCellDelegate {
  func updateQuestion(index: Int, data: MeetingQuestionCellModel) {
    viewModel.updateQuestion(index: index, data: data)
  }
  
  func addQuestion() {
    viewModel.questionList.append("")
    viewModel.addQuestion()
    let indexPathRow = viewModel.questionList.count - 1
    let newIndex = IndexPath(row: indexPathRow, section: MeetingQuestionSectionType.questionSection.index)
    tableView.performBatchUpdates(
      {
        tableView.insertRows(at: [newIndex], with: .automatic)
      }, completion: nil)
    
    guard let currentCell = tableView.cellForRow(at: newIndex) as? QuestionTableViewCell else {
      return
    }
    
    currentCell.inputTextView.textView.becomeFirstResponder()
  }
  
  func presentQuestionDeleteBottomSheet(index: Int) {
    let questionFilledList = viewModel.questionListBehaviorRelay.value
    let lastQuestion = questionFilledList
      .map { $0.isFilled }
      .filter { $0 == true }
      .count == 1
    
    let vc = QuestionDeleteBottomSheetViewController(index: index, lastQuestion: lastQuestion)
    vc.delegate = self
    vc.modalPresentationStyle = .overFullScreen
    present(vc, animated: false)
  }
  
  func updateHeightOfRow(_ cell: QuestionTableViewCell, _ textView: UITextView) {
    let size = textView.bounds.size
    let newSize = tableView.sizeThatFits(CGSize(width: size.width, height: .infinity))
    if size.height != newSize.height {
      UIView.setAnimationsEnabled(false)
      tableView.beginUpdates()
      tableView.endUpdates()
      UIView.setAnimationsEnabled(true)
    }
  }
}

extension MeetingQuestionViewController: QuestionDeleteBottomSheetDelegate {
  func removeQuestion(index: Int, lastQuestion: Bool) {
    viewModel.questionList.remove(at: index)
    viewModel.removeQuestion(index: index)
    
    if lastQuestion {
      chageQuestionMode(state: true)
      questionHeaderView.setQuestionButtonState(state: false)
    } else {
      tableView.reloadData()
      view.endEditing(true)
      hideAddQuestionButton(state: !viewModel.allQuestionFilled.value)
    }
  }
}

extension MeetingQuestionViewController: QuestionHeaderViewCellDelegate {
  func chageQuestionMode(state: Bool) {
    if !state && viewModel.questionList.count == 0 {
      viewModel.questionList.append("")
      viewModel.addQuestion()
    }
    viewModel.noQuestionMode.accept(state)
    tableView.reloadData()
  }
}

extension MeetingQuestionViewController {
  private func hideAddQuestionButton(state: Bool) {
    let addQuestionIndex = IndexPath(row: 0, section: MeetingQuestionSectionType.addQuestionSection.index)
    guard let currentCell = self.tableView.cellForRow(at: addQuestionIndex) as? AddQuestionTableViewCell else {
      return
    }
    currentCell.addQuestionControl.isHidden = state
  }
}
