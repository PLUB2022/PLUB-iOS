//
//  ApplyQuestionViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/04.
//

import UIKit

import RxSwift
import SnapKit
import Then

final class ApplyQuestionViewController: BaseViewController {
  
  private let viewModel: ApplyQuestionViewModelType
  
  private var models: [ApplyQuestionTableViewCellModel] = [] {
    didSet {
      questionTableView.reloadData()
    }
  }
  
  private var isActive: Bool = false {
    didSet {
      self.applyButton.isEnabled = isActive
      self.questionHeaderView.isActive = isActive
    }
  }
  
  private let questionHeaderView = ApplyQuestionHeaderView()
  
  private lazy var questionTableView = UITableView(frame: .zero, style: .grouped).then {
    $0.separatorStyle = .none
    $0.register(ApplyQuestionTableViewCell.self, forCellReuseIdentifier: ApplyQuestionTableViewCell.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.rowHeight = UITableView.automaticDimension
    $0.estimatedRowHeight = 86 + 16
    $0.backgroundColor = .background
  }
  
  private let applyButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "지원하기")
  }
  
  init(viewModel: ApplyQuestionViewModelType = ApplyQuestionViewModel(), plubbingID: Int) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    bind(plubbingID: plubbingID)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    let tap = UITapGestureRecognizer(target: self.view, action: #selector(view.endEditing(_:)))
    view.isUserInteractionEnabled = true
    view.addGestureRecognizer(tap)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [questionHeaderView, questionTableView, applyButton].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    questionHeaderView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(Device.navigationBarHeight)
      $0.directionalHorizontalEdges.equalTo(view.safeAreaLayoutGuide)
      $0.height.lessThanOrEqualTo(120)
    }
    
    questionTableView.snp.makeConstraints {
      $0.top.equalTo(questionHeaderView.snp.bottom).offset(37.5)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
    
    applyButton.snp.makeConstraints {
      $0.directionalHorizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.bottom.equalToSuperview()
      $0.height.equalTo(46)
    }
  }
  
  func bind(plubbingID: Int) {
    super.bind()
    
    viewModel.whichRecruitment.onNext(plubbingID)
    
    viewModel.allQuestion
      .drive(rx.models)
      .disposed(by: disposeBag)
    
    viewModel.isActivated
      .drive(rx.isActive)
      .disposed(by: disposeBag)
    
    applyButton.rx.tap
      .subscribe(viewModel.selectApply)
      .disposed(by: disposeBag)
    
    viewModel.isSuccessApply
      .drive(with: self) { owner,  _ in
        let alert = HomeAlertController()
        alert.modalPresentationStyle = .overFullScreen
        alert.delegate = owner
        owner.present(alert, animated: false)
      }
      .disposed(by: disposeBag)
    
  }
}

extension ApplyQuestionViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return models.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ApplyQuestionTableViewCell.identifier, for: indexPath) as? ApplyQuestionTableViewCell ?? ApplyQuestionTableViewCell()
    cell.configureUI(with: models[indexPath.row])
    cell.delegate = self
    return cell
  }
  
}

extension ApplyQuestionViewController: ApplyQuestionTableViewCellDelegate {
  func whatQuestionAnswer(_ answer: ApplyAnswer) {
    viewModel.whichApplyRequest.onNext(answer)
  }
  
  func whichQuestionChangedIn(_ status: QuestionStatus) {
    viewModel.whichQuestion.onNext(status)
  }
  
  func updateHeightOfRow(_ cell: ApplyQuestionTableViewCell, _ textView: UITextView) {
    let size = textView.bounds.size
    let newSize = questionTableView.sizeThatFits(CGSize(width: size.width,
                                                        height: .infinity))
    if size.height != newSize.height {
      UIView.setAnimationsEnabled(false)
      questionTableView.beginUpdates()
      questionTableView.endUpdates()
      UIView.setAnimationsEnabled(true)
      if let thisIndexPath = questionTableView.indexPath(for: cell) {
        questionTableView.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
      }
    }
  }
}

extension ApplyQuestionViewController: HomeAlertDelegate {
  func dismissHomeAlert() {
    navigationController?.popViewController(animated: false)
  }
}
