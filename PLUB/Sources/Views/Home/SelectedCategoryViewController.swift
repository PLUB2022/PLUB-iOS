//
//  InterestListViewController.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit

import SnapKit
import Then

enum SelectedCategoryType {
  case chart
  case grid
}

class SelectedCategoryViewController: BaseViewController {
  
  private let viewModel: SelectedCategoryViewModelType
  
  private var selectedCategoryCollectionViewCellModels: [SelectedCategoryCollectionViewCellModel] = []
  
  private var selectedCategoryType: SelectedCategoryType = .chart
  
  private lazy var interestListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then({
    $0.scrollDirection = .vertical
    $0.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
  })).then {
    $0.backgroundColor = .systemBackground
  }.then {
    $0.register(SelectedCategoryGridCollectionViewCell.self, forCellWithReuseIdentifier: SelectedCategoryGridCollectionViewCell.identifier)
    $0.register(SelectedCategoryChartCollectionViewCell.self, forCellWithReuseIdentifier: SelectedCategoryChartCollectionViewCell.identifier)
    $0.register(SelectedCategoryFilterHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SelectedCategoryFilterHeaderView.identifier)
  }
  
  private lazy var interestListNavigationBar = SelectedCategoryNavigationBar().then {
    $0.configureUI(with: title ?? "")
  }
  
  init(viewModel: SelectedCategoryViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    view.backgroundColor = .systemBackground
    self.navigationController?.navigationBar.isHidden = true
    
    interestListNavigationBar.delegate = self
    interestListCollectionView.delegate = self
    interestListCollectionView.dataSource = self
  }
  
  override func setupLayouts() {
    [interestListNavigationBar, interestListCollectionView].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    interestListNavigationBar.snp.makeConstraints {
      $0.top.left.right.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(70)
    }
    
    interestListCollectionView.snp.makeConstraints {
      $0.top.equalTo(interestListNavigationBar.snp.bottom)
      $0.left.right.bottom.equalToSuperview()
    }
  }
  
  override func bind() {
    viewModel.createSelectedCategoryChartCollectionViewCellModels()
      .subscribe(onNext: { [weak self] selectedCategoryChartCollectionViewCellModels in
        guard let `self` = self else { return }
        self.selectedCategoryCollectionViewCellModels = selectedCategoryChartCollectionViewCellModels
      })
      .disposed(by: disposeBag)
  }
}

extension SelectedCategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return selectedCategoryCollectionViewCellModels.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch selectedCategoryType {
    case .chart:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedCategoryChartCollectionViewCell.identifier, for: indexPath) as? SelectedCategoryChartCollectionViewCell ?? SelectedCategoryChartCollectionViewCell()
      cell.configureUI(with: selectedCategoryCollectionViewCellModels[indexPath.row])
      return cell
    case .grid:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedCategoryGridCollectionViewCell.identifier, for: indexPath) as? SelectedCategoryGridCollectionViewCell ?? SelectedCategoryGridCollectionViewCell()
      cell.configureUI(with: selectedCategoryCollectionViewCellModels[indexPath.row])
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
      return CGSize(width: collectionView.frame.width - 10 - 10, height: collectionView.frame.height / 4 - 10)
    case .grid:
      return CGSize(width: collectionView.frame.width / 2 - 10 - 10, height: collectionView.frame.height / 2.5)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let vc = IntroduceCategoryViewController(model: selectedCategoryCollectionViewCellModels[indexPath.row])
    vc.navigationItem.largeTitleDisplayMode = .never
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension SelectedCategoryViewController: SelectedCategoryNavigationBarDelegate {
  func didTappedBackButton() {
    self.navigationController?.navigationBar.isHidden = false
    self.navigationController?.popViewController(animated: true)
  }
  
  func didTappedSearchButton() {

  }
}

extension SelectedCategoryViewController: SelectedCategoryFilterHeaderViewDelegate {
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
