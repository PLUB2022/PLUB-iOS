//
//  MeetingQuestionViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/09.
//

import UIKit

import RxSwift

enum MeetingQuestionSectionType: Int, CaseIterable {
  //TODO: 수빈 - title, button 뷰 tableViewCell에 넣기
  //  case titleSection = 0
  //  case buttonSection = 1
  case questionSection = 0
  case addQuestionSection = 1
  
  var index: Int {
    return self.rawValue
  }
  
  var height: CGFloat {
    switch self {
      //TODO: 수빈 - title, button 뷰 tableViewCell에 넣기
      //    case .titleSection:
      //      return 70
      //    case .buttonSection:
      //      return 142
    case .questionSection, .addQuestionSection:
      return UITableView.automaticDimension
    }
  }
}

final class MeetingQuestionViewController: BaseViewController {
  
  private var viewModel: MeetingQuestionViewModel
  weak var delegate: CreateMeetingChildViewControllerDelegate?
  private var childIndex: Int
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 48
  }
  
  private let titleView = CreateMeetingTitleView(
    title: "어떤 게스트가 오면 좋을까요?",
    description: "함께 할 게스트에게 질문하고 싶은 내용을 적어주세요!\n꼭 적지 않아도 괜찮아요."
  )
  
  private let questionStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 16
    $0.distribution = .fillEqually
  }
  
  private let questionButton: UIButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "질문 하고 모집하기")
  }
  
  private let noquestionButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "질문 없이 모집하기")
  }
  
  private lazy var tableView = UITableView().then {
    $0.separatorStyle = .none
    $0.showsVerticalScrollIndicator = false
    $0.backgroundColor = .background
    $0.delegate = self
    $0.dataSource = self
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
    [contentStackView, tableView].forEach {
      view.addSubview($0)
    }
    
    [titleView, questionStackView].forEach {
      contentStackView.addArrangedSubview($0)
    }
    
    [questionButton, noquestionButton].forEach {
      questionStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    contentStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    tableView.snp.makeConstraints {
      $0.top.equalTo(contentStackView.snp.bottom).offset(48)
      $0.leading.trailing.bottom.equalToSuperview()
    }
    
    [questionButton, noquestionButton].forEach{
      $0.snp.makeConstraints {
        $0.height.equalTo(46)
      }
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
    questionButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.questionButton.isSelected = true
        owner.noquestionButton.isSelected = false
      })
      .disposed(by: disposeBag)
    
    noquestionButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.questionButton.isSelected = false
        owner.noquestionButton.isSelected = true
      })
      .disposed(by: disposeBag)
    
    viewModel.allQuestionFilled
      .subscribe(onNext: { state in
        self.delegate?.checkValidation(
          index: self.childIndex,
          state: state
        )
        let addQuestionIndex = IndexPath(row: 0, section: MeetingQuestionSectionType.addQuestionSection.index)
        guard let currentCell = self.tableView.cellForRow(at: addQuestionIndex) as? AddQuestionTableViewCell else {
          return
        }
        currentCell.addQuestionControl.isHidden = !(state && self.viewModel.questionList.count < 5)
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
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case MeetingQuestionSectionType.questionSection.index:
      return viewModel.questionList.count
    case MeetingQuestionSectionType.addQuestionSection.index:
      return 1
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
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
    let vc = QuestionDeleteBottomSheetViewController(index: index)
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
  func removeQuestion(index: Int) {
    viewModel.questionList.remove(at: index)
    viewModel.removeQuestion(index: index)
    tableView.reloadData()
    view.endEditing(true)
  }
}
