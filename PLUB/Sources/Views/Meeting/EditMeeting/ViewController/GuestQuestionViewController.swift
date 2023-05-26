//
//  GuestQuestionViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/10.
//

import UIKit

import RxSwift
import RxCocoa

final class GuestQuestionViewController: BaseViewController {
  private let viewModel: GuestQuestionViewModel
  weak var delegate: EditMeetingChildViewControllerDelegate?
  
  private let questionStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 16
    $0.distribution = .fillEqually
  }
  
  private let questionButton: UIButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "질문 하고 모집하기")
    $0.isSelected = true
  }
  
  private let noquestionButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "질문 없이 모집하기")
  }
  
  private lazy var tableView = UITableView(frame: CGRect.zero, style: .grouped).then {
    $0.separatorStyle = .none
    $0.showsVerticalScrollIndicator = false
    $0.backgroundColor = .background
    $0.delegate = self
    $0.dataSource = self
    $0.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 56))
    $0.register(QuestionTableViewCell.self, forCellReuseIdentifier: QuestionTableViewCell.identifier)
    $0.register(AddQuestionTableViewCell.self, forCellReuseIdentifier: AddQuestionTableViewCell.identifier)
    $0.keyboardDismissMode = .onDrag
  }
  
  private let saveButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "저장")
  }
  
  private let tapGesture = UITapGestureRecognizer(
    target: RecruitPostViewController.self,
      action: nil
  ).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  init(viewModel: GuestQuestionViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.fetchMeetingData()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerKeyboardNotification()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillAppear(animated)
    removeKeyboardNotification()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [questionStackView, tableView, saveButton].forEach {
      view.addSubview($0)
    }
    
    [questionButton, noquestionButton].forEach {
      questionStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    questionStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(40)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.height.equalTo(46)
    }
    
    tableView.snp.makeConstraints {
      $0.top.equalTo(questionStackView.snp.bottom).offset(48)
      $0.leading.bottom.trailing.equalToSuperview()
    }
    
    saveButton.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(26)
      $0.height.width.equalTo(46)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
    
    [questionButton, noquestionButton].forEach{
      $0.snp.makeConstraints {
        $0.height.equalTo(46)
      }
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "질문 리스트"
  }
  
  override func bind() {
    super.bind()
    
    viewModel.fetchedMeetingData
      .withLatestFrom(viewModel.noQuestionMode)
      .withUnretained(self)
      .subscribe(onNext: { owner, mode in
        owner.setQuestionButtonState(state: !mode)
        owner.tableView.reloadData()
      })
      .disposed(by: disposeBag)
    
    questionButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.setQuestionButtonState(state: true)
        owner.chageQuestionMode(state: false)
      })
      .disposed(by: disposeBag)
    
    noquestionButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.setQuestionButtonState(state: false)
        owner.chageQuestionMode(state: true)
      })
      .disposed(by: disposeBag)
    
    viewModel.allQuestionFilled
      .withUnretained(self)
      .subscribe(onNext: { owner, state in
        owner.hideAddQuestionButton(state: !(state && owner.viewModel.questionList.count < 5))
      })
      .disposed(by: disposeBag)
    
    Observable.combineLatest(
      viewModel.allQuestionFilled,
      viewModel.noQuestionMode
    )
      .withUnretained(self)
      .subscribe(onNext: { owner, tuple in
        owner.saveButton.isEnabled = tuple.0 || tuple.1
      })
      .disposed(by: disposeBag)
    
    tapGesture.rx.event
      .asDriver()
      .drive(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.view.endEditing(true)
      })
      .disposed(by: disposeBag)
    
    saveButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.viewModel.requestEditMeeting()
      }
      .disposed(by: disposeBag)
    
    viewModel.successEditQuestion
      .withUnretained(self)
      .subscribe(onNext: { owner, state in
        owner.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  private func setupMeetingData(data: EditMeetingInfoRequest) {
    
  }
  
  func setQuestionButtonState(state: Bool) {
    questionButton.isSelected = state
    noquestionButton.isSelected = !state
  }
  
  func chageQuestionMode(state: Bool) {
    if !state && viewModel.questionList.count == 0 {
      viewModel.questionList.append("")
      viewModel.addQuestion()
    }
    viewModel.noQuestionMode.accept(state)
    tableView.reloadData()
  }
}

// MARK: - UITableViewDelegate

extension GuestQuestionViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return UIView()
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
}

// MARK: - UITableViewDataSource

extension GuestQuestionViewController: UITableViewDataSource {
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

// MARK: - QuestionTableViewCellDelegate

extension GuestQuestionViewController: QuestionTableViewCellDelegate {
  func updateQuestion(index: Int, data: MeetingQuestionCellModel) {
    viewModel.updateQuestion(index: index, data: data)
  }
  
  func addQuestion() {
    viewModel.questionList.append("")
    viewModel.addQuestion()
    let indexPathRow = viewModel.questionList.count - 1
    let newIndex = IndexPath(row: indexPathRow, section: MeetingQuestionSectionType.questionSection.index)
    tableView.performBatchUpdates(
      { tableView.insertRows(at: [newIndex], with: .automatic) },
      completion: nil
    )
    
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
    present(vc, animated: true)
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
  
  func scrollToRow(_ cell: QuestionTableViewCell) {
    if let thisIndexPath = tableView.indexPath(for: cell) {
      tableView.scrollToRow(at: thisIndexPath, at: .middle, animated: false)
    }
  }
}

// MARK: - QuestionDeleteBottomSheetDelegate

extension GuestQuestionViewController: QuestionDeleteBottomSheetDelegate {
  func removeQuestion(index: Int, lastQuestion: Bool) {
    viewModel.questionList.remove(at: index)
    viewModel.removeQuestion(index: index)
    
    if lastQuestion {
      chageQuestionMode(state: true)
      setQuestionButtonState(state: false)
    } else {
      tableView.reloadData()
      view.endEditing(true)
      hideAddQuestionButton(state: !viewModel.allQuestionFilled.value)
    }
  }
}

// MARK: - Custom Function

extension GuestQuestionViewController {
  private func hideAddQuestionButton(state: Bool) {
    let addQuestionIndex = IndexPath(row: 0, section: MeetingQuestionSectionType.addQuestionSection.index)
    guard let currentCell = self.tableView.cellForRow(at: addQuestionIndex) as? AddQuestionTableViewCell else {
      return
    }
    currentCell.addQuestionControl.isHidden = state
  }
}

// MARK: - Keyboard

extension GuestQuestionViewController {
  func registerKeyboardNotification() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                             name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                             name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  func removeKeyboardNotification() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  func keyboardWillShow(_ sender: Notification) {
    tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 56 + 26))
    if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      let keyboardHeight: CGFloat = keyboardSize.height
      saveButton.snp.updateConstraints {
        $0.bottom.equalToSuperview().inset(keyboardHeight + 26)
      }
      view.layoutIfNeeded()
    }
  }
  
  @objc
  func keyboardWillHide(_ sender: Notification) {
    tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 56))
    saveButton.snp.updateConstraints {
      $0.bottom.equalToSuperview().inset(26)
    }
    view.layoutIfNeeded()
  }
}
