//
//  SearchOutputHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/03.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

protocol SearchOutputHeaderViewDelegate: AnyObject {
  func didTappedInterestListChartButton()
  func didTappedInterestListGridButton()
  func didTappedSortControl()
  func whichTappedSegmentControl(index: Int)
}

class SearchOutputHeaderView: UIView {
  
  private let disposeBag = DisposeBag()
  
  weak var delegate: SearchOutputHeaderViewDelegate?
  
  var filterChanged: SortType = .popular {
    didSet {
      sortButton.sortChanged = filterChanged
    }
  }
  
  private let segmentedControl = UnderlineSegmentedControl(
    items: [FilterType.title.toKor, FilterType.mix.toKor, FilterType.name.toKor]
  ).then {
    $0.setTitleTextAttributes([.foregroundColor: UIColor.black, .font: UIFont.body1!], for: .normal)
    $0.setTitleTextAttributes([.foregroundColor: UIColor.main, .font: UIFont.body1!], for: .selected)
    $0.selectedSegmentIndex = 0
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
    [segmentedControl, sortButton, interestListChartButton, interesetListGridButton].forEach { addSubview($0) }
    
    segmentedControl.snp.makeConstraints {
      $0.top.width.equalToSuperview()
      $0.height.equalTo(32)
    }
    
    interesetListGridButton.snp.makeConstraints {
      $0.trailing.equalToSuperview()
      $0.top.equalTo(segmentedControl.snp.bottom)
    }
    
    interestListChartButton.snp.makeConstraints {
      $0.top.equalTo(segmentedControl.snp.bottom)
      $0.trailing.equalTo(interesetListGridButton.snp.leading)
    }
    
    sortButton.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.centerY.equalTo(interestListChartButton)
    }
  }
  
  private func bind() {
    
    segmentedControl.rx.value
      .subscribe(with: self) { owner, index in
        owner.delegate?.whichTappedSegmentControl(index: index)
      }
      .disposed(by: disposeBag)
      
    
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
