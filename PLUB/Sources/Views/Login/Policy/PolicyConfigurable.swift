//
//  PolicyConfigurable.swift
//  PLUB
//
//  Created by νμΉν on 2022/12/18.
//

import Foundation

protocol PolicyConfigurable {
  func configure(with model: PolicyViewModel.Item)
}


extension PolicyHeaderTableViewCell: PolicyConfigurable {
  func configure(with model: PolicyViewModel.Item) {
    guard let policy = model.policy else { return }
    if model.type != .header { return }
    configure(with: policy)
  }
}

extension PolicyBodyTableViewCell: PolicyConfigurable {
  func configure(with model: PolicyViewModel.Item) {
    guard let url = model.url else { return }
    if model.type != .body { return }
    configure(with: url)
  }
}
