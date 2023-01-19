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
  
  private lazy var tableView: UITableView = UITableView().then {
    $0.backgroundColor = .background
    $0.register(PolicyHeaderTableViewCell.self, forCellReuseIdentifier: PolicyHeaderTableViewCell.identifier)
    $0.register(PolicyBodyTableViewCell.self, forCellReuseIdentifier: PolicyBodyTableViewCell.identifier)
    $0.separatorStyle = .none
    $0.delegate = self
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.setTableView(tableView)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(tableView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    tableView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
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
