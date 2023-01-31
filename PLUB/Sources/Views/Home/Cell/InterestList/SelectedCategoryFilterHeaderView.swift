//
//  InterestListFilterHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit

import RxSwift

protocol SelectedCategoryFilterHeaderViewDelegate: AnyObject {
  func didTappedInterestListFilterButton()
  func didTappedInterestListChartButton()
  func didTappedInterestListGridButton()
  func didTappedSortControl()
}

final class SelectedCategoryFilterHeaderView: UICollectionReusableView {
  static let identifier = "InterestListFilterHeaderView"
  
  weak var delegate: SelectedCategoryFilterHeaderViewDelegate?
  private var disposeBag = DisposeBag()
  
  var filterChanged: SortType = .popular {
    didSet {
      sortButton.sortChanged = filterChanged
    }
  }
  
  private let interestListFilterLabel = UILabel().then {
    $0.text = "전체"
    $0.font = .body1
    $0.textColor = .black
  }
  
  private let interestListFilterButton = UIButton().then {
    $0.setImage(UIImage(named: "filter"), for: .normal)
  }
  
  private let interestListChartButton = UIButton().then {
    $0.setImage(UIImage(named: "chart"), for: .normal)
  }
  
  private let interesetListGridButton = UIButton().then {
    $0.setImage(UIImage(named: "grid"), for: .normal)
  }
  
  private let sortButton = SortControl()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    interestListFilterButton.addTarget(self, action: #selector(didTappedInterestListFilterButton), for: .touchUpInside)
    interestListChartButton.addTarget(self, action: #selector(didTappedInterestListChartButton), for: .touchUpInside)
    interesetListGridButton.addTarget(self, action: #selector(didTappedInterestListGridButton), for: .touchUpInside)
    
    [interestListFilterLabel, interestListFilterButton, interestListChartButton, interesetListGridButton, sortButton].forEach { addSubview($0) }
    
    interestListFilterLabel.snp.makeConstraints {
      $0.centerY.left.equalToSuperview()
    }
    
    interestListFilterButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.left.equalTo(interestListFilterLabel.snp.right)
      $0.size.equalTo(32)
    }
    
    sortButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.right.equalToSuperview()
    }
    
    interesetListGridButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.right.equalTo(sortButton.snp.left)
    }
    
    interestListChartButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.right.equalTo(interesetListGridButton.snp.left)
    }
  }
  
  private func bind() {
    sortButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.delegate?.didTappedSortControl()
      })
      .disposed(by: disposeBag)
  }
  
  @objc private func didTappedInterestListFilterButton() {
    delegate?.didTappedInterestListFilterButton()
  }
  
  @objc private func didTappedInterestListChartButton() {
    delegate?.didTappedInterestListChartButton()
  }
  
  @objc private func didTappedInterestListGridButton() {
    delegate?.didTappedInterestListGridButton()
  }
}
