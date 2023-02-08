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
//  case emp
}

final class SelectedCategoryViewController: BaseViewController {
  
  private let viewModel: SelectedCategoryViewModelType
  
  private var model: [SelectedCategoryCollectionViewCellModel] = [] {
    didSet {
      interestListCollectionView.reloadData()
    }
  }
  
  private var type: SortType = .popular {
    didSet {
      interestListCollectionView.reloadSections([0])
      viewModel.whichSortType.onNext(type)
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
  
  private let noSelectedCategoryView = NoSelectedCategoryView()
  
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
    [interestListCollectionView, noSelectedCategoryView].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    interestListCollectionView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(10)
    }
    
    noSelectedCategoryView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(50 + 139)
      $0.left.right.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }
  
  func bind(categoryID: String) {
    viewModel.selectCategoryID.onNext(categoryID)
    
    viewModel.updatedCellData
      .drive(rx.model)
      .disposed(by: disposeBag)
    
    viewModel.isEmpty
      .map { !$0 }
      .emit(to: noSelectedCategoryView.rx.isHidden)
      .disposed(by: disposeBag)
  }
  
  @objc private func didTappedBackButton() {
    self.navigationController?.popViewController(animated: true)
  }
}

extension SelectedCategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if section == 1 {
      return model.count
    }
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if indexPath.section == 0 && kind == UICollectionView.elementKindSectionHeader {
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SelectedCategoryFilterHeaderView.identifier, for: indexPath) as? SelectedCategoryFilterHeaderView ?? SelectedCategoryFilterHeaderView()
      header.filterChanged = type
      header.delegate = self
      return header
    }
    else { return UICollectionReusableView() }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if section == 0 {
      return CGSize(width: collectionView.frame.width, height: 50)
    }
    return .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
    vc.delegate = self
    vc.configureUI(with: type)
    present(vc, animated: false)
  }
  
  func didTappedInterestListFilterButton() {
    
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

extension SelectedCategoryViewController: SortBottomSheetViewControllerDelegate {
  func didTappedSortButton(type: SortType) {
    self.type = type
  }
}

extension SelectedCategoryViewController: SelectedCategoryChartCollectionViewCellDelegate {
  func didTappedChartBookmarkButton(plubbingID: String) {
    viewModel.tappedBookmark.onNext(plubbingID)
  }
}

extension SelectedCategoryViewController: SelectedCategoryGridCollectionViewCellDelegate {
  func didTappedGridBookmarkButton(plubbingID: String) {
    viewModel.tappedBookmark.onNext(plubbingID)
  }
}
