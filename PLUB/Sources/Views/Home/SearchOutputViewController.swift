//
//  SearchOutputViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/27.
//

import UIKit

import SnapKit
import Then

final class SearchOutputViewController: BaseViewController {
  
  private let model: [SelectedCategoryCollectionViewCellModel]
  
  private var selectedCategoryType: SelectedCategoryType = .chart
  
  private var type: SortType = .popular {
    didSet {
      interestListCollectionView.reloadSections([0])
//      viewModel.whichSortType.onNext(type)
    }
  }
  
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
  
  init(model: [SelectedCategoryCollectionViewCellModel]) {
    print("검색아웃풋모델 = \(model)")
    self.model = model
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupConstraints() {
    interestListCollectionView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(10)
    }
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(interestListCollectionView)
  }
}

extension SearchOutputViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        return cell
      case .grid:
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedCategoryGridCollectionViewCell.identifier, for: indexPath) as? SelectedCategoryGridCollectionViewCell ?? SelectedCategoryGridCollectionViewCell()
        cell.configureUI(with: model[indexPath.row])
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

extension SearchOutputViewController: SelectedCategoryFilterHeaderViewDelegate {
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

extension SearchOutputViewController: SortBottomSheetViewControllerDelegate {
  func didTappedSortButton(type: SortType) {
    self.type = type
  }
}
