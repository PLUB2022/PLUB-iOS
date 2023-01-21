//
//  PolicyViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2022/12/10.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class PolicyViewController: BaseViewController {
  
  private let viewModel = PolicyViewModel()
  
  private let agreementControl = UIControl().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 8
    $0.layer.shadowColor = UIColor(hex: 0x000000).withAlphaComponent(0.1).cgColor
    $0.layer.shadowOpacity = 1
    $0.layer.shadowRadius = 10
    $0.layer.shadowOffset = CGSize(width: 0, height: 2)
  }
  
  private let agreementLabel = UILabel().then {
    $0.text = "전체 동의"
    $0.font = .subtitle
    $0.textColor = .black
  }
  
  private let agreementCheckboxButton = CheckBoxButton(type: .full)
  
  private lazy var tableView = UITableView().then {
    $0.backgroundColor = .background
    $0.register(PolicyHeaderTableViewCell.self, forCellReuseIdentifier: PolicyHeaderTableViewCell.identifier)
    $0.register(PolicyBodyTableViewCell.self, forCellReuseIdentifier: PolicyBodyTableViewCell.identifier)
    $0.separatorStyle = .none
    $0.delegate = self
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.setTableView(tableView)
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(agreementControl)
    view.addSubview(tableView)
    
    agreementControl.addSubview(agreementLabel)
    agreementControl.addSubview(agreementCheckboxButton)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    agreementControl.snp.makeConstraints {
      $0.top.horizontalEdges.equalToSuperview()
      $0.height.equalTo(48)
    }
    
    agreementLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().inset(16)
    }
    
    agreementCheckboxButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.size.equalTo(24)
      $0.trailing.equalToSuperview().inset(12)
    }
    
    tableView.snp.makeConstraints {
      $0.top.equalTo(agreementControl.snp.bottom).offset(16)
      $0.horizontalEdges.bottom.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    
    let output = viewModel.transform(input: .init(allAgreementButtonTapped: agreementCheckboxButton.rx.tap.asObservable()))
    
    output.checkedButtonListState
      .do { print($0) }
      .map { $0.reduce(true, { $0 && $1 }) }
      .drive(onNext: { [weak self] in
        self?.agreementCheckboxButton.isChecked = $0
      })
      .disposed(by: disposeBag)
    
    output.checkedButtonListState
      .map { $0.dropLast(1).reduce(true, { $0 && $1 }) }
      .drive(onNext: { flag in
        // delegate 처리
      })
      .disposed(by: disposeBag)
  }
}


extension PolicyViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    viewModel.loadNextSnapshots(for: indexPath)
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct PolicyViewControllerPreview: PreviewProvider {
  static var previews: some View {
    PolicyViewController().toPreview()
  }
}
#endif
