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

final class SelectedCategoryViewController: BaseViewController {
  
  private let viewModel: SelectedCategoryViewModelType
  
  private var model: [SelectedCategoryCollectionViewCellModel] = [] {
    didSet {
      interestListCollectionView.reloadData()
    }
  }
  
  private var type: SortType = .popular {
    didSet {
      viewModel.whichSortType.onNext(type)
      selectedCategoryFilterHeaderView.filterChanged = type
      interestListCollectionView.reloadData()
    }
  }
  
  private var selectedCategoryType: SelectedCategoryType = .chart
  
  private lazy var selectedCategoryFilterHeaderView = SelectedCategoryFilterHeaderView().then {
    $0.delegate = self
  }
  
  private lazy var interestListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.scrollDirection = .vertical
  }).then {
    $0.backgroundColor = .background
  }.then {
    $0.register(SelectedCategoryGridCollectionViewCell.self, forCellWithReuseIdentifier: SelectedCategoryGridCollectionViewCell.identifier)
    $0.register(SelectedCategoryChartCollectionViewCell.self, forCellWithReuseIdentifier: SelectedCategoryChartCollectionViewCell.identifier)
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
    [selectedCategoryFilterHeaderView, interestListCollectionView, noSelectedCategoryView].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    selectedCategoryFilterHeaderView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(10)
      $0.leading.trailing.equalToSuperview().inset(10)
      $0.height.equalTo(50)
    }
    
    interestListCollectionView.snp.makeConstraints {
      $0.top.equalTo(selectedCategoryFilterHeaderView.snp.bottom)
      $0.leading.trailing.bottom.equalToSuperview().inset(10)
    }
    
    noSelectedCategoryView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(50 + 139)
      $0.leading.trailing.equalToSuperview()
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
    
    viewModel.isBookmarked.emit(onNext: { isBookmarked in
      print("해당 모집글을 북마크 \(isBookmarked)")
    })
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
        cell.delegate = self
        return cell
      case .grid:
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedCategoryGridCollectionViewCell.identifier, for: indexPath) as? SelectedCategoryGridCollectionViewCell ?? SelectedCategoryGridCollectionViewCell()
        cell.configureUI(with: model[indexPath.row])
        cell.delegate = self
        return cell
      }
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
    vc.delegate = self
    vc.configureUI(with: type)
    present(vc, animated: false)
  }
  
  func didTappedInterestListFilterButton() {
    
  }
  
  func didTappedInterestListChartButton() {
    self.selectedCategoryType = .chart
    self.interestListCollectionView.reloadData()
  }
  
  func didTappedInterestListGridButton() {
    self.selectedCategoryType = .grid
    self.interestListCollectionView.reloadData()
  }
}

extension SelectedCategoryViewController: SortBottomSheetViewControllerDelegate {
  func didTappedSortButton(type: SortType) {
    self.type = type
    dismiss(animated: false)
  }
}

extension SelectedCategoryViewController: SelectedCategoryChartCollectionViewCellDelegate, SelectedCategoryGridCollectionViewCellDelegate {
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

