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
  
  private var model: [SelectedCategoryCollectionViewCellModel] = [] {
    didSet {
      interestListCollectionView.reloadSections([1])
    }
  }
  
  private var selectedCategoryType: SelectedCategoryType = .chart
  
  private var type: SortType = .popular {
    didSet {
      interestListCollectionView.reloadSections([0])
      viewModel.whichSortType.onNext(type)
    }
  }
  
  private lazy var interestListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then({
    $0.scrollDirection = .vertical
    $0.sectionHeadersPinToVisibleBounds = true
  })).then {
    $0.backgroundColor = .background
  }.then {
    $0.register(SelectedCategoryGridCollectionViewCell.self, forCellWithReuseIdentifier: SelectedCategoryGridCollectionViewCell.identifier)
    $0.register(SelectedCategoryChartCollectionViewCell.self, forCellWithReuseIdentifier: SelectedCategoryChartCollectionViewCell.identifier)
    $0.register(SearchOutputHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchOutputHeaderView.identifier)
    $0.delegate = self
    $0.dataSource = self
  }
  
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
    $0.register(RecentSearchListHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RecentSearchListHeaderView.identifier)
    $0.delegate = self
    $0.dataSource = self
  }
  
  private let searchAlertView = SearchAlertView()
  private let noResultSearchView = NoResultSearchView()
  
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
    interestListCollectionView.isHidden = true
    noResultSearchView.isHidden = true
  }
  
  override func setupConstraints() {
    recentSearchListView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    searchAlertView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    interestListCollectionView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(10)
    }
    
    noResultSearchView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(64)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [recentSearchListView, searchAlertView, interestListCollectionView, noResultSearchView].forEach { view.addSubview($0) }
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
      .withUnretained(self)
      .subscribe(onNext: { owner, text in
        owner.noResultSearchView.configureUI(with: text)
        owner.viewModel.whichKeyword.onNext(text)
        owner.interestListCollectionView.isHidden = false
      })
      .disposed(by: disposeBag)
    
    viewModel.fetchedSearchOutput
      .drive(rx.model)
      .disposed(by: disposeBag)
    
    viewModel.currentRecentKeyword
      .drive(rx.currentKeywordList)
      .disposed(by: disposeBag)
    
    searchBar.rx.text.orEmpty
      .skip(1)
      .filter { $0.isEmpty }
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.recentSearchListView.isHidden = false
        owner.interestListCollectionView.isHidden = true
        owner.noResultSearchView.isHidden = true
      })
      .disposed(by: disposeBag)
    
    viewModel.keywordListIsEmpty
      .map { !$0 }
      .drive(searchAlertView.rx.isHidden)
      .disposed(by: disposeBag)
    
    viewModel.searchOutputIsEmpty
      .map { !$0 }
      .drive(noResultSearchView.rx.isHidden)
      .disposed(by: disposeBag)
    
    viewModel.isBookmarked.emit(onNext: { isBookmarked in
      print("해당 모집글을 북마크 \(isBookmarked)")
    })
    .disposed(by: disposeBag)
    
  }
  
  @objc private func didTappedBackButton() {
    if interestListCollectionView.isHidden == false || noResultSearchView.isHidden == false {
      interestListCollectionView.isHidden = true
      noResultSearchView.isHidden = true
    }
    else {
      self.navigationController?.popViewController(animated: true)
    }
  }
}

extension SearchInputViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    if collectionView == recentSearchListView {
      return 1
    }
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == recentSearchListView {
      return currentKeywordList.count
    }
    else { // interestListCollectionView 일때
      if section == 1 {
        return model.count
      }
      return 0
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == UICollectionView.elementKindSectionHeader && collectionView == recentSearchListView {
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RecentSearchListHeaderView.identifier, for: indexPath) as? RecentSearchListHeaderView ?? RecentSearchListHeaderView()
      header.delegate = self
      return header
    }
    else {
      if indexPath.section == 0 && kind == UICollectionView.elementKindSectionHeader {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SearchOutputHeaderView.identifier, for: indexPath) as? SearchOutputHeaderView ?? SearchOutputHeaderView()
        header.filterChanged = type
        header.delegate = self
        return header
      }
      else { return UICollectionReusableView() }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == interestListCollectionView {
      let vc = DetailRecruitmentViewController(plubbingID: model[indexPath.row].plubbingID)
      vc.navigationItem.largeTitleDisplayMode = .never
      self.navigationController?.pushViewController(vc, animated: true)
    } else if collectionView == recentSearchListView {
      guard let cell = collectionView.cellForItem(at: indexPath) as? RecentSearchListCollectionViewCell,
            let keyword = cell.searchkeyword else { return }
      self.searchBar.text = keyword
      self.noResultSearchView.configureUI(with: keyword)
      self.viewModel.whichKeyword.onNext(keyword)
      self.interestListCollectionView.isHidden = false
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if collectionView == recentSearchListView {
      return CGSize(width: collectionView.frame.width, height: 26)
    }
    else {
      if section == 0 {
        return CGSize(width: collectionView.frame.width, height: 64)
      }
      return .zero
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == recentSearchListView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentSearchListCollectionViewCell.identifier, for: indexPath) as? RecentSearchListCollectionViewCell ?? RecentSearchListCollectionViewCell()
      cell.configureUI(with: currentKeywordList[indexPath.row])
      cell.delegate = self
      return cell
    }
    else {
      if indexPath.section == 1 {
        switch selectedCategoryType {
        case .chart:
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedCategoryChartCollectionViewCell.identifier, for: indexPath) as? SelectedCategoryChartCollectionViewCell ?? SelectedCategoryChartCollectionViewCell()
          cell.configureUI(with: model[indexPath.row])
          cell.delegate = self
          return cell
        case .grid:
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedCategoryGridCollectionViewCell.identifier, for: indexPath) as? SelectedCategoryGridCollectionViewCell ?? SelectedCategoryGridCollectionViewCell()
          cell.configureUI(with: model[indexPath.row])
          cell.delegate = self
          return cell
        }
      }
      return UICollectionViewCell()
    }
  }
}

extension SearchInputViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == recentSearchListView {
      return CGSize(width: collectionView.frame.width / 2 - 6 - 16, height: 32)
    }
    else {
      if indexPath.section == 1 {
        switch selectedCategoryType {
        case .chart:
          return CGSize(width: collectionView.frame.width, height: collectionView.frame.height / 4 - 6)
        case .grid:
          return CGSize(width: collectionView.frame.width / 2 - 6, height: collectionView.frame.height / 2.5)
        }
      }
      return .zero
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    if collectionView == interestListCollectionView {
      return 12
    }
    return .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    if collectionView == interestListCollectionView {
      return 12
    }
    return .zero
  }
}

extension SearchInputViewController: RecentSearchListCollectionViewCellDelegate {
  func didTappedRemoveButton(cell: UICollectionViewCell) {
    guard let indexPath = recentSearchListView.indexPath(for: cell) else { return }
    viewModel.whichKeywordRemove.onNext(indexPath.row)
  }
}

extension SearchInputViewController: RecentSearchListHeaderViewDelegate {
  func didTappedRemoveAllButton() {
    viewModel.tappedRemoveAll.onNext(())
  }
}

extension SearchInputViewController: SearchOutputHeaderViewDelegate {
  func didTappedTopBar(which: IndexPath) {
    
  }
  
  func didTappedSortControl() {
    let vc = SortBottomSheetViewController()
    vc.modalPresentationStyle = .overFullScreen
    vc.delegate = self
    vc.configureUI(with: type)
    present(vc, animated: false)
  }
  
  func didTappedInterestListChartButton() {
    self.selectedCategoryType = .chart
    self.interestListCollectionView.reloadSections([1])
  }
  
  func didTappedInterestListGridButton() {
    self.selectedCategoryType = .grid
    self.interestListCollectionView.reloadSections([1])
  }
}

extension SearchInputViewController: SortBottomSheetViewControllerDelegate {
  func didTappedSortButton(type: SortType) {
    self.type = type
    dismiss(animated: false)
  }
}

extension SearchInputViewController: SelectedCategoryChartCollectionViewCellDelegate, SelectedCategoryGridCollectionViewCellDelegate {
  func updateBookmarkState(isBookmarked: Bool, cell: UICollectionViewCell) {
    guard let indexPath = interestListCollectionView.indexPath(for: cell) else { return }
    model[indexPath.row].isBookmarked = isBookmarked
  }
  
  func didTappedChartBookmarkButton(plubbingID: String) {
    viewModel.tappedBookmark.onNext(plubbingID)
  }
  
  func didTappedGridBookmarkButton(plubbingID: String) {
    viewModel.tappedBookmark.onNext(plubbingID)
  }
}
