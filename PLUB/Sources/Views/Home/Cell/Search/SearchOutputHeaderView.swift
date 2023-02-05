//
//  SearchOutputHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/03.
//

import UIKit

import RxSwift
import SnapKit
import Then

protocol SearchOutputHeaderViewDelegate: AnyObject {
  func didTappedInterestListChartButton()
  func didTappedInterestListGridButton()
  func didTappedSortControl()
}

class SearchOutputHeaderView: UICollectionReusableView {
  
  static let identifier = "SearchOutputHeaderView"
  private let disposeBag = DisposeBag()
  
  weak var delegate: SearchOutputHeaderViewDelegate?
  
  var filterChanged: SortType = .popular {
    didSet {
      sortButton.sortChanged = filterChanged
    }
  }
  
  private let topTabCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
    $0.backgroundColor = .background
  }
  
  private let sortButton = SortControl()
  
  private let interestListChartButton = ToggleButton(type: .chart)
  
  private let interesetListGridButton = ToggleButton(type: .grid)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    interestListChartButton.isSelected = true
    [topTabCollectionView, sortButton, interestListChartButton, interesetListGridButton].forEach { addSubview($0) }
    
    topTabCollectionView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(32)
    }
    
    interesetListGridButton.snp.makeConstraints {
      $0.right.equalToSuperview()
      $0.top.equalTo(topTabCollectionView.snp.bottom)
    }
    
    interestListChartButton.snp.makeConstraints {
      $0.top.equalTo(topTabCollectionView.snp.bottom)
      $0.right.equalTo(interesetListGridButton.snp.left)
    }
    
    sortButton.snp.makeConstraints {
      $0.left.equalToSuperview()
      $0.centerY.equalTo(interestListChartButton)
    }
  }
  
  private func bind() {
    sortButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.delegate?.didTappedSortControl()
      })
      .disposed(by: disposeBag)
    
    
    interestListChartButton.buttonTapObservable
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.interesetListGridButton.isSelected = false
        owner.delegate?.didTappedInterestListChartButton()
      })
      .disposed(by: disposeBag)
    
    interestListChartButton.buttonUnTapObservable
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.interestListChartButton.isSelected = true
      })
      .disposed(by: disposeBag)
    
    interesetListGridButton.buttonTapObservable
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.interestListChartButton.isSelected = false
        owner.delegate?.didTappedInterestListGridButton()
      })
      .disposed(by: disposeBag)
    
    interesetListGridButton.buttonUnTapObservable
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.interesetListGridButton.isSelected = true
      })
      .disposed(by: disposeBag)
  }
}


