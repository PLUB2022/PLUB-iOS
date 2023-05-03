//
//  ExportViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/23.
//

import UIKit

import SnapKit
import Then

final class ExportViewController: BaseViewController {
  private let viewModel: ExportViewModel
  
  private let titleLabel = UILabel().then {
    $0.font = .h2
    $0.textColor = .black
    $0.text = "플러버 리스트"
  }
  
  private let tableView = UITableView().then {
    $0.separatorStyle = .none
    $0.showsVerticalScrollIndicator = false
    $0.backgroundColor = .background
    $0.register(ExportTableViewCell.self, forCellReuseIdentifier: ExportTableViewCell.identifier)
  }
  
  init(viewModel: ExportViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [titleLabel, tableView].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
      $0.height.equalTo(33)
    }
    
    tableView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(36)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    viewModel.accountList
      .drive(tableView.rx.items) { [weak self] tableView, row, item -> UITableViewCell in
        guard let cell = tableView.dequeueReusableCell(
          withIdentifier: ExportTableViewCell.identifier,
          for: IndexPath(row: row, section: 0)
        ) as? ExportTableViewCell else { return UITableViewCell() }
        cell.setupData(with: item, indexPathRow: row)
        cell.delegate = self
        return cell
      }
      .disposed(by: disposeBag)
    
    viewModel.successExport
      .drive(with: self) { owner, nickname in
        owner.showSuccessExportMemberAlert(nickname: nickname)
      }
      .disposed(by: disposeBag)
  }
}

extension ExportViewController {
  private func showSuccessExportMemberAlert(nickname: String) {
    let alert = CustomAlertView(
      AlertModel(
        title: "“\(nickname)”님을\n강퇴하였습니다",
        message: nil,
        cancelButton: nil,
        confirmButton: nil,
        height: 162
      )
    ) { }
    alert.show()
  }
}

extension ExportViewController: ExportTableViewCellDelegate {
  func didTappedExportButton(nickname: String, indexPathRow: Int) {
    let alert = CustomAlertView(
      AlertModel(
        title: "“\(nickname)”님을\n강퇴하시겠어요?",
        message: nil,
        cancelButton: "취소",
        confirmButton: "네, 할게요",
        height: 210
      )
    ) { [weak self] in
      guard let self else { return }
      self.viewModel.exportMember(indexPathRow: indexPathRow)
    }
    alert.show()
  }
}
