//
//  BookmarkViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/16.
//

import UIKit

import SnapKit
import Then

final class BookmarkViewController: BaseViewController {
  
  private let viewModel: BookmarkViewModelType
  
  private var model: [SelectedCategoryCollectionViewCellModel] = [] {
    didSet {
      interestListCollectionView.reloadData()
    }
  }
  
  private var selectedCategoryType: SelectedCategoryType = .chart
  
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
  
  init(viewModel: BookmarkViewModelType = BookmarkViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    self.navigationItem.title = nil
    self.navigationItem.leftBarButtonItems = [
      UIBarButtonItem(image: UIImage(named: "back"), style: .done, target: self, action: #selector(didTappedBackButton)),
      UIBarButtonItem(title: title, style: .done, target: nil, action: nil)
    ]
  }
  
  override func bind() {
    super.bind()
    viewModel.updatedCellData
      .emit(onNext: { data in
        print("데이터 = \(data)")
      })
      .disposed(by: disposeBag)
  }
  
  @objc private func didTappedBackButton() {
    self.navigationController?.popViewController(animated: true)
  }
}

extension BookmarkViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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

extension BookmarkViewController: SelectedCategoryChartCollectionViewCellDelegate, SelectedCategoryGridCollectionViewCellDelegate {
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
