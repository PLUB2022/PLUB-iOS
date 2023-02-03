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

final class SearchInputViewController: BaseViewController {
  
  private let viewModel: SearchInputViewModelType
  
  private var currentKeywordList: [String] = [] {
    didSet {
      recentSearchListView.reloadData()
    }
  }
  
  private let searchBar = UISearchBar().then {
    $0.placeholder = "검색할 내용을 입력해주세요"
    $0.returnKeyType = .search
    $0.spellCheckingType = .no
    $0.autocorrectionType = .no
    $0.autocapitalizationType = .none
  }
  
  private lazy var recentSearchListView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 8
    $0.minimumInteritemSpacing = 12
  }).then {
    $0.backgroundColor = .background
    $0.contentInset = UIEdgeInsets(top: 3, left: 16, bottom: .zero, right: 16)
    $0.register(RecentSearchListCollectionViewCell.self, forCellWithReuseIdentifier: RecentSearchListCollectionViewCell.identifier)
    $0.delegate = self
    $0.dataSource = self
  }
  
  private let searchAlertView = SearchAlertView()
  
  init(viewModel: SearchInputViewModelType = SearchInputViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
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
  
  override func setupConstraints() {
    searchAlertView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    recentSearchListView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [searchAlertView, recentSearchListView].forEach { view.addSubview($0) }
  }
  
  override func bind() {
    super.bind()
    searchBar.rx.searchButtonClicked
      .do(onNext: { [weak self] _ in
        self?.searchBar.resignFirstResponder()
      })
      .throttle(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
        .withLatestFrom(searchBar.rx.text.orEmpty)
        .filter { $0.count != 0 }
        .distinctUntilChanged()
        .withUnretained(self)
        .subscribe(onNext: { owner, text in
          owner.viewModel.whichKeyword.onNext(text)
        })
        .disposed(by: disposeBag)
    
    viewModel.fetchedSearchOutput
      .drive(onNext: { model in
        let vc = SearchOutputViewController(model: model)
        vc.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    viewModel.currentRecentKeyword
      .asObservable()
      .withUnretained(self)
      .subscribe(onNext: { owner, list in
        owner.currentKeywordList = list
      })
      .disposed(by: disposeBag)
  }
  
  @objc private func didTappedBackButton() {
    self.navigationController?.popViewController(animated: true)
  }
}

extension SearchInputViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return currentKeywordList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentSearchListCollectionViewCell.identifier, for: indexPath) as? RecentSearchListCollectionViewCell ?? RecentSearchListCollectionViewCell()
    cell.configureUI(with: currentKeywordList[indexPath.row])
    cell.delegate = self
    return cell
  }
}

extension SearchInputViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width / 2 - 6 - 16, height: 32)
  }
}

extension SearchInputViewController: RecentSearchListCollectionViewCellDelegate {
  func didTappedRemoveButton(cell: UICollectionViewCell) {
    let indexPath = recentSearchListView.indexPath(for: cell)
  }
}
