//
//  ApplyQuestionViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/04.
//

import UIKit
import SnapKit
import Then
import RxSwift

class ApplyQuestionViewController: BaseViewController {
  
  private lazy var questionTableView = UITableView(frame: .zero, style: .grouped).then {
    $0.backgroundColor = .secondarySystemBackground
    $0.separatorStyle = .none
    $0.register(ApplyQuestionTableViewCell.self, forCellReuseIdentifier: ApplyQuestionTableViewCell.identifier)
    $0.register(ApplyQuestionTableHeaderView.self, forHeaderFooterViewReuseIdentifier: ApplyQuestionTableHeaderView.identifier)
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .secondarySystemBackground
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(didTappedBackButton))
    
    let tap = UITapGestureRecognizer(target: self.view, action: #selector(view.endEditing(_:)))
    view.isUserInteractionEnabled = true
    view.addGestureRecognizer(tap)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(questionTableView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    questionTableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    questionTableView.rx.setDelegate(self).disposed(by: disposeBag)
    questionTableView.rx.setDataSource(self).disposed(by: disposeBag)
  }
  
  @objc private func didTappedBackButton() {
    
  }
}

extension ApplyQuestionViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ApplyQuestionTableViewCell.identifier, for: indexPath) as? ApplyQuestionTableViewCell ?? ApplyQuestionTableViewCell()
    cell.configureUI(with: .init(question: "\(indexPath.row + 1). 질문", placeHolder: "소개하는 내용을 입력해주세요"))
    cell.delegate = self
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 0 {
      let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ApplyQuestionTableHeaderView.identifier) as? ApplyQuestionTableHeaderView ?? ApplyQuestionTableHeaderView()
      header.configureUI(with: "")
      return header
    }
    return nil
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return 120
    }
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
