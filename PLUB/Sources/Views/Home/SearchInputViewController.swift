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
  
  private let searchBar = UISearchBar().then {
    $0.placeholder = "검색할 내용을 입력해주세요"
    $0.returnKeyType = .search
    $0.spellCheckingType = .no
    $0.autocorrectionType = .no
    $0.autocapitalizationType = .none
  }
  
  private let searchAlertView = SearchAlertView()
  
  private var model: [SelectedCategoryCollectionViewCellModel] = [] {
    didSet {
      interestListCollectionView.reloadData()
    }
  }
  
  private var selectedCategoryType: SelectedCategoryType = .chart
  
  private lazy var interestListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then({
    $0.scrollDirection = .vertical
  })).then {
    $0.backgroundColor = .background
  }.then {
    $0.register(SelectedCategoryGridCollectionViewCell.self, forCellWithReuseIdentifier: SelectedCategoryGridCollectionViewCell.identifier)
    $0.register(SelectedCategoryChartCollectionViewCell.self, forCellWithReuseIdentifier: SelectedCategoryChartCollectionViewCell.identifier)
    $0.register(SelectedCategoryFilterHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SelectedCategoryFilterHeaderView.identifier)
    $0.delegate = self
    $0.dataSource = self
  }
  
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
    interestListCollectionView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(10)
    }
    
    searchAlertView.snp.makeConstraints {
      $0.edges.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(interestListCollectionView)
    view.addSubview(searchAlertView)
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
      .drive(onNext: { content in
        print("콘텐츠 = \(content)")
      })
      .disposed(by: disposeBag)
  }
  
  @objc private func didTappedBackButton() {
    self.navigationController?.popViewController(animated: true)
  }
}

extension SearchInputViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return model.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch selectedCategoryType {
    case .chart:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedCategoryChartCollectionViewCell.identifier, for: indexPath) as? SelectedCategoryChartCollectionViewCell ?? SelectedCategoryChartCollectionViewCell()
      cell.configureUI(with: model[indexPath.row])
      return cell
    case .grid:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedCategoryGridCollectionViewCell.identifier, for: indexPath) as? SelectedCategoryGridCollectionViewCell ?? SelectedCategoryGridCollectionViewCell()
      cell.configureUI(with: model[indexPath.row])
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if collectionView == self.interestListCollectionView && kind == UICollectionView.elementKindSectionHeader {
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SelectedCategoryFilterHeaderView.identifier, for: indexPath) as? SelectedCategoryFilterHeaderView ?? SelectedCategoryFilterHeaderView()
      header.delegate = self
      return header
    }
    else { return UICollectionReusableView() }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 50)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch selectedCategoryType {
    case .chart:
      return CGSize(width: collectionView.frame.width, height: collectionView.frame.height / 4 - 6)
    case .grid:
      return CGSize(width: collectionView.frame.width / 2 - 6, height: collectionView.frame.height / 2.5)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 12
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 12
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let vc = DetailRecruitmentViewController(plubbingID: model[indexPath.row].plubbingID)
    vc.navigationItem.largeTitleDisplayMode = .never
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension SearchInputViewController: SelectedCategoryFilterHeaderViewDelegate {
  func didTappedSortControl() {
    
  }
  
  func didTappedInterestListFilterButton() {
    
  }
  
  func didTappedInterestListChartButton() {
    self.selectedCategoryType = .chart
    self.interestListCollectionView.reloadSections([0])
  }
  
  func didTappedInterestListGridButton() {
    self.selectedCategoryType = .grid
    self.interestListCollectionView.reloadSections([0])
  }
}
