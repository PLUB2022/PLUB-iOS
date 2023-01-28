//
//  SearchInputViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/27.
//

import UIKit

import SnapKit
import Then

class SearchInputViewController: BaseViewController {
  
  private let searchBar = UISearchBar().then {
    $0.placeholder = "검색할 내용을 입력해주세요"
  }
  
  private let searchAlertView = SearchAlertView()
  
  override func setupStyles() {
    super.setupStyles()
    self.navigationItem.titleView = searchBar
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "back"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(searchAlertView)
    searchAlertView.snp.makeConstraints {
      $0.edges.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  @objc private func didTappedBackButton() {
    self.navigationController?.popViewController(animated: true)
  }
}
