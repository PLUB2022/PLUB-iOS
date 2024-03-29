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
  
  private let categoryID: String
  
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
  
  private lazy var noSelectedCategoryView = NoSelectedCategoryView().then {
    $0.delegate = self
  }
  
  init(viewModel: SelectedCategoryViewModelType = SelectedCategoryViewModel(), categoryID: String) {
    self.viewModel = viewModel
    self.categoryID = categoryID
    super.init(nibName: nil, bundle: nil)
    bind(categoryID: categoryID)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayouts() {
    [selectedCategoryFilterHeaderView, interestListCollectionView, noSelectedCategoryView].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    selectedCategoryFilterHeaderView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(10)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.height.equalTo(50)
    }
    
    interestListCollectionView.snp.makeConstraints {
      $0.top.equalTo(selectedCategoryFilterHeaderView.snp.bottom)
      $0.leading.trailing.bottom.equalToSuperview().inset(16)
    }
    
    noSelectedCategoryView.snp.makeConstraints {
      $0.top.equalTo(selectedCategoryFilterHeaderView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide)
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
      Log.debug("해당 모집글을 북마크 \(isBookmarked)")
    })
    .disposed(by: disposeBag)
    
    interestListCollectionView.rx.didScroll
      .subscribe(with: self, onNext: { owner, _ in
        let offSetY = owner.interestListCollectionView.contentOffset.y
        let contentHeight = owner.interestListCollectionView.contentSize.height
        
        if offSetY > (contentHeight - owner.interestListCollectionView.frame.size.height + 100) {
          owner.viewModel.fetchMoreDatas.onNext(())
        }
      })
      .disposed(by: disposeBag)
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
      return CGSize(width: collectionView.frame.width, height: 176)
    case .grid:
      return CGSize(width: collectionView.frame.width / 2 - 6, height: 252)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 12
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 12
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let model = model[indexPath.row]
    let vc = DetailRecruitmentViewController(plubbingID: model.plubbingID)
    vc.navigationItem.largeTitleDisplayMode = .never
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension SelectedCategoryViewController: SelectedCategoryFilterHeaderViewDelegate {
  func didTappedSortControl() {
    let vc = SortBottomSheetViewController()
    vc.delegate = self
    vc.configureUI(with: type)
    present(vc, animated: true)
  }
  
  func didTappedInterestListFilterButton() {
    let vc = RecruitmentFilterViewController(viewModel: RecruitmentFilterViewModel(categoryID: Int(categoryID)!))
    vc.delegate = self
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.title = title
    self.navigationController?.pushViewController(vc, animated: true)
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
    dismiss(animated: true)
  }
}

extension SelectedCategoryViewController: SelectedCategoryChartCollectionViewCellDelegate, SelectedCategoryGridCollectionViewCellDelegate {
  func updateBookmarkState(isBookmarked: Bool, cell: UICollectionViewCell) {
    guard let indexPath = interestListCollectionView.indexPath(for: cell) else { return }
    model[indexPath.row].isBookmarked = isBookmarked
  }
  
  func didTappedChartBookmarkButton(plubbingID: Int) {
    viewModel.tappedBookmark.onNext(plubbingID)
  }
  
  func didTappedGridBookmarkButton(plubbingID: Int) {
    viewModel.tappedBookmark.onNext(plubbingID)
  }
}

extension SelectedCategoryViewController: NoSelectedCategoryViewDelegate {
  func didTappedCreateMeetingButton() {
    let vc = CreateMeetingViewController()
    vc.navigationItem.largeTitleDisplayMode = .never
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension SelectedCategoryViewController: RecruitmentFilterDelegate {
  func didTappedConfirmButton(request: CategoryMeetingRequest) {
    viewModel.whichFilterRequest.onNext(request)
  }
}
