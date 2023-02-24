//
//  RecruitmentFilterViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/12.
//

import UIKit

import SnapKit
import Then

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

final class RecruitmentFilterViewController: BaseViewController {
  
  private let subCategories: [RecruitmentFilterCollectionViewCellModel]
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 24, weight: .semibold)
    $0.sizeToFit()
  }
  
  private lazy var filterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.sectionInset = UIEdgeInsets(top: .zero, left: .zero, bottom: 32, right: .zero)
  }).then {
    $0.backgroundColor = .background
    $0.register(RecruitmentFilterCollectionViewCell.self, forCellWithReuseIdentifier: RecruitmentFilterCollectionViewCell.identifier)
    $0.register(RecruitmentFilterCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RecruitmentFilterCollectionHeaderView.identifier)
    $0.contentInset = UIEdgeInsets(top: .zero, left: 16, bottom: .zero, right: 16)
    $0.delegate = self
    $0.dataSource = self
  }
  
  private let recruitmentFilterSlider = RecruitmentFilterSlider()
  
  private let confirmButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "확인")
  }
  
  init(subCategories: [RecruitmentFilterCollectionViewCellModel]) {
    self.subCategories = subCategories
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "back"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    
    self.navigationItem.title = nil
    titleLabel.text = title
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.leading.equalToSuperview().inset(16)
    }
    
    filterCollectionView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(32)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(139 + 32 + 99)
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
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension RecruitmentFilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return RecruitmentFilterSection.allCases.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 8
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let section = RecruitmentFilterSection.allCases[indexPath.section]
    switch section {
    case .detailCategory:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecruitmentFilterCollectionViewCell.identifier, for: indexPath) as? RecruitmentFilterCollectionViewCell ?? RecruitmentFilterCollectionViewCell()
      cell.configureUI(with: "헬스")
      return cell
    case .day:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecruitmentFilterCollectionViewCell.identifier, for: indexPath) as? RecruitmentFilterCollectionViewCell ?? RecruitmentFilterCollectionViewCell()
      cell.configureUI(with: Day.allCases[indexPath.row].kor)
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RecruitmentFilterCollectionHeaderView.identifier, for: indexPath) as? RecruitmentFilterCollectionHeaderView ?? RecruitmentFilterCollectionHeaderView()
    header.configureUI(with: RecruitmentFilterSection.allCases[indexPath.section].title)
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? RecruitmentFilterCollectionViewCell else { return }
    cell.isTapped.toggle()
  }
}

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
