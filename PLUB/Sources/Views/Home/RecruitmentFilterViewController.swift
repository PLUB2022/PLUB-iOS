//
//  RecruitmentFilterViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/12.
//

import UIKit

import SnapKit
import Then

// 모집필터섹션에 따른 구분을 위한 타입
enum RecruitmentFilterSection: CaseIterable {
  case detailCategory
  case day
  
  var title: String {
    switch self {
    case .detailCategory:
      return "세부 카테고리"
    case .day:
      return "모임 요일"
    }
  }
}

protocol RecruitmentFilterDelegate: AnyObject {
  func didTappedConfirmButton(request: CategoryMeetingRequest) // 모집 필터를 위한 Request데이터를 전달하기위함
}

final class RecruitmentFilterViewController: BaseViewController {
  
  // MARK: - Properties
  
  weak var delegate: RecruitmentFilterDelegate?
  
  private let viewModel: RecruitmentFilterViewModelType
  
  // MARK: - UI Models
  
  private var subCategories: [RecruitmentFilterCollectionViewCellModel] = [] { // 서브카테고리를 위한 데이터
    didSet {
      guard !self.subCategories.isEmpty else { return }
      filterCollectionView.snp.updateConstraints {
        $0.height.equalTo(Double(19 + 8 + 32 + 99) + ceil(Double(subCategories.count) / Double(4)) * 32 + (ceil(Double(subCategories.count) / Double(4)) - 1) * 8)
      }
      filterCollectionView.reloadData()
    }
  }
  
  private var filterDays: [RecruitmentFilterDateCollectionViewCellModel] = [] { // 요일을 위한 데이터
    didSet {
      filterCollectionView.reloadData()
    }
  }
  
  // MARK: - UI Components
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 24, weight: .semibold)
    $0.sizeToFit()
  }
  
  private lazy var filterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
    $0.backgroundColor = .background
    $0.register(RecruitmentFilterCollectionViewCell.self, forCellWithReuseIdentifier: RecruitmentFilterCollectionViewCell.identifier)
    $0.register(RecruitmentFilterDateCollectionViewCell.self, forCellWithReuseIdentifier: RecruitmentFilterDateCollectionViewCell.identifier)
    $0.register(RecruitmentFilterCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RecruitmentFilterCollectionHeaderView.identifier)
    $0.contentInset = UIEdgeInsets(top: .zero, left: 16, bottom: .zero, right: 16)
    $0.delegate = self
    $0.dataSource = self
    $0.isScrollEnabled = false
  }
  
  private let recruitmentFilterSlider = RecruitmentFilterSlider()
  
  private let confirmButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "확인")
  }
  
  // MARK: - Initialization
  
  init(viewModel: RecruitmentFilterViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  override func bind() {
    super.bind()
    
    viewModel.selectedSubCategories
      .emit(to: rx.subCategories)
      .disposed(by: disposeBag)
    
    viewModel.fetchedDayModel
      .emit(to: rx.filterDays)
      .disposed(by: disposeBag)
    
    viewModel.isButtonEnabled
      .drive(confirmButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    confirmButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.viewModel.confirmAccountNum.onNext(owner.recruitmentFilterSlider.accountNum)
        owner.viewModel.filterConfirm.onNext(())
      }
      .disposed(by: disposeBag)
    
    viewModel.confirmRequest
      .emit(with: self) { owner, request in
        owner.delegate?.didTappedConfirmButton(request: request)
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()    
    self.navigationItem.title = nil
    titleLabel.text = title
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.leading.equalToSuperview().inset(16)
      $0.height.equalTo(29)
    }
    
    filterCollectionView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(32)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(Double(19 + 8 + 32 + 99) + ceil(Double(subCategories.count) / Double(4)) * 32 + (ceil(Double(subCategories.count) / Double(4)) - 1) * 8) // 헤더라벨높이 + 헤더 셀 사이 + 섹션간 사이 + 요일섹션고정높이 + (서브카테고리 총수 / 한 행 데이터 수) * 셀 높이 + ((서브카테고리 총수 / 한 행 데이터 수) - 1) * miniLine값
    }
    
    recruitmentFilterSlider.snp.makeConstraints {
      $0.top.equalTo(filterCollectionView.snp.bottom).offset(32)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.height.equalTo(67)
    }
    
    confirmButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(26)
      $0.height.equalTo(46)
    }
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [titleLabel, filterCollectionView, recruitmentFilterSlider, confirmButton].forEach { view.addSubview($0) }
  }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension RecruitmentFilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return RecruitmentFilterSection.allCases.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let section = RecruitmentFilterSection.allCases[section]
    switch section {
    case .detailCategory:
      return subCategories.count
    case .day:
      return filterDays.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let section = RecruitmentFilterSection.allCases[indexPath.section]
    switch section {
    case .detailCategory:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecruitmentFilterCollectionViewCell.identifier, for: indexPath) as? RecruitmentFilterCollectionViewCell ?? RecruitmentFilterCollectionViewCell()
      cell.configureUI(with: subCategories[indexPath.row])
      return cell
    case .day:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecruitmentFilterDateCollectionViewCell.identifier, for: indexPath) as? RecruitmentFilterDateCollectionViewCell ?? RecruitmentFilterDateCollectionViewCell()
      cell.configureUI(with: filterDays[indexPath.row])
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RecruitmentFilterCollectionHeaderView.identifier, for: indexPath) as? RecruitmentFilterCollectionHeaderView ?? RecruitmentFilterCollectionHeaderView()
    header.configureUI(with: RecruitmentFilterSection.allCases[indexPath.section].title)
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let section = RecruitmentFilterSection.allCases[indexPath.section]
    switch section {
    case .detailCategory:
      let isSelect = subCategories[indexPath.row].tappedSubCategory()
      let subCategoryID = subCategories[indexPath.row].subCategoryID
      viewModel.isSelectSubCategory.onNext((isSelect, subCategoryID))
    case .day:
      let isSelect = filterDays[indexPath.row].tappedDay()
      viewModel.isSelectDay.onNext((isSelect, Day.allCases[indexPath.row]))
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    let section = RecruitmentFilterSection.allCases[section]
    switch section {
    case .detailCategory:
      return UIEdgeInsets.init(top: .zero, left: .zero, bottom: 16, right: .zero)
    case .day:
      return .zero
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RecruitmentFilterViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width / 4 - 3 - 16, height: 32)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 8
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 12
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 19 + 8)
  }
}
