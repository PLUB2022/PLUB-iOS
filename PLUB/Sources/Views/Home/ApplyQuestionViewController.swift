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

class ApplyQuestionViewController: BaseViewController {
  
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
    $0.backgroundColor = .secondarySystemBackground
    $0.separatorStyle = .none
    $0.register(ApplyQuestionTableViewCell.self, forCellReuseIdentifier: ApplyQuestionTableViewCell.identifier)
  }
  
  private let applyButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "지원하기")
  }
  
  init(viewModel: ApplyQuestionViewModelType = ApplyQuestionViewModel(), plubbingID: String) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    bind(plubbingID: plubbingID)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .background
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "back"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    
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
      $0.left.right.equalTo(view.safeAreaLayoutGuide)
      $0.height.lessThanOrEqualTo(120)
    }
    
    questionTableView.snp.makeConstraints {
      $0.top.equalTo(questionHeaderView.snp.bottom).offset(37.5)
      $0.left.right.bottom.equalToSuperview()
    }
    
    applyButton.snp.makeConstraints {
      $0.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.bottom.equalToSuperview()
      $0.height.equalTo(46)
    }
  }
  
  func bind(plubbingID: String) {
    super.bind()
    
    viewModel.whichRecruitment.onNext(plubbingID)
    
    viewModel.allQuestion
      .drive(rx.models)
      .disposed(by: disposeBag)
    
    viewModel.isActivated
      .drive(rx.isActive)
      .disposed(by: disposeBag)
    
    applyButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in HomeAlert.shared.showAlert(on: owner)})
      .disposed(by: disposeBag)
    
    questionTableView.rx.setDelegate(self).disposed(by: disposeBag)
    questionTableView.rx.setDataSource(self).disposed(by: disposeBag)
  }
  
  @objc private func didTappedBackButton() {
    self.navigationController?.popViewController(animated: true)
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
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return .leastNonzeroMagnitude
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .leastNonzeroMagnitude
  }
}

extension ApplyQuestionViewController: ApplyQuestionTableViewCellDelegate {
  func whichQuestionChangedIn(_ status: QuestionStatus) {
    viewModel.whichQuestion.onNext(status)
  }
  
  func textViewDidChange(text: String, _ textView: UITextView) {
    applyButton.isEnabled = text.isEmpty ? false : true
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
