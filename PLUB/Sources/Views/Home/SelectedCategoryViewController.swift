//
//  InterestListViewController.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit

import RxSwift
import SnapKit
import Then

enum SelectedCategoryType {
  case chart
  case grid
}

class SelectedCategoryViewController: BaseViewController {
  
  private let viewModel: SelectedCategoryViewModelType
  
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
  
  init(viewModel: SelectedCategoryViewModelType = SelectedCategoryViewModel(), categoryID: String) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    bind(categoryID: categoryID)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    view.backgroundColor = .background
    
    self.navigationItem.title = nil
    self.navigationItem.leftBarButtonItems = [
      UIBarButtonItem(image: UIImage(named: "back"), style: .done, target: self, action: #selector(didTappedBackButton)),
      UIBarButtonItem(title: title, style: .done, target: nil, action: nil)
    ]
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "search"),
      style: .done,
      target: self,
      action: nil
    )
  }
  
  override func setupLayouts() {
    view.addSubview(interestListCollectionView)
  }
  
  override func setupConstraints() {
    interestListCollectionView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(10)
    }
  }
  
  func bind(categoryID: String) {
    viewModel.selectCategoryID.onNext(categoryID)
    
    viewModel.updatedCellData
      .drive(rx.model)
      .disposed(by: disposeBag)
  }
  
  @objc private func didTappedBackButton() {
    self.navigationController?.popViewController(animated: true)
  }
}

extension SelectedCategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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

extension SelectedCategoryViewController: SelectedCategoryFilterHeaderViewDelegate {
  func didTappedSortControl() {
    let vc = SortBottomSheetViewController()
    vc.modalPresentationStyle = .overFullScreen
    present(vc, animated: false)
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

