//
//  SearchInputViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/27.
//

import UIKit

import RxSwift
import SnapKit
import Then

class SearchInputViewController: BaseViewController {
  
  private let searchBar = UISearchBar().then {
    $0.placeholder = "검색할 내용을 입력해주세요"
    $0.returnKeyType = .search
    $0.spellCheckingType = .no
    $0.autocorrectionType = .no
    $0.autocapitalizationType = .none
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
  
  override func bind() {
    super.bind()
    searchBar.rx.searchButtonClicked
      .do(onNext: { [weak self] _ in
        self?.searchBar.resignFirstResponder()
      })
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .withLatestFrom(searchBar.rx.text.orEmpty)
      .filter { $0.count != 0 }
      .distinctUntilChanged()
      .subscribe(onNext: { text in
        print("tete = \(text)")
      })
      .disposed(by: disposeBag)
  }
  
  @objc private func didTappedBackButton() {
    self.navigationController?.popViewController(animated: true)
  }
}


