//
//  PolicyViewController.swift
//  PLUB
//
//  Created by νμΉν on 2022/12/10.
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
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}


extension PolicyViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    viewModel.loadNextSnapshots(for: .init(rawValue: indexPath.section)!)
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
