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
  
  private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
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
    [tableView].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    tableView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    setupNavigationBar()
  }
  
  override func bind() {
    super.bind()
    viewModel.accountList
      .drive(tableView.rx.items) { tableView, row, item -> UITableViewCell in
        guard let cell = tableView.dequeueReusableCell(
          withIdentifier: ExportTableViewCell.identifier,
          for: IndexPath(row: row, section: 0)
        ) as? ExportTableViewCell else { return UITableViewCell() }
        cell.setupData(with: item, indexPathRow: row)
        cell.delegate = self
        return cell
      }
      .disposed(by: disposeBag)
  }
}

extension ExportViewController {
  private func setupNavigationBar() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "backButton"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
  }
  
  @objc
  private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}
