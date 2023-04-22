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
    $0.register(MyPageTableViewCell.self, forCellReuseIdentifier: MyPageTableViewCell.identifier)
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
  }
  
  override func setupConstraints() {
    super.setupConstraints()
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
          withIdentifier: "LocationTableViewCell",
          for: IndexPath(row: row, section: 0)
        ) as? LocationTableViewCell else { return UITableViewCell() }
//        cell.setupData(
//          with: LocationTableViewCellModel(
//            title: item.placeName ?? "",
//            subTitle: item.address ?? ""
//          )
//        )
        return cell
      }
      .disposed(by: disposeBag)
    
    tableView.rx.didScroll
      .subscribe { [weak self] _ in

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
