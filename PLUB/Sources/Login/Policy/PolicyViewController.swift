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
  
  
  private lazy var tableView: UITableView = UITableView().then {
    $0.backgroundColor = .background
    $0.register(PolicyHeaderTableViewCell.self, forCellReuseIdentifier: PolicyHeaderTableViewCell.identifier)
    $0.register(PolicyTableViewCell.self, forCellReuseIdentifier: PolicyTableViewCell.identifier)
    $0.separatorStyle = .none
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


#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct PolicyViewControllerPreview: PreviewProvider {
  static var previews: some View {
    PolicyViewController().toPreview()
  }
}
#endif

