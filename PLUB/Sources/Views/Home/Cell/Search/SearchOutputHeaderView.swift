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
  
  private let topTabbar = TopTabbar()
  
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
    [topTabbar, sortButton, interestListChartButton, interesetListGridButton].forEach { addSubview($0) }
    
    topTabbar.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(32)
    }
    
    interesetListGridButton.snp.makeConstraints {
      $0.right.equalToSuperview()
      $0.top.equalTo(topTabbar.snp.bottom)
    }
    
    interestListChartButton.snp.makeConstraints {
      $0.top.equalTo(topTabbar.snp.bottom)
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

class TopTabbar: UIView {
  
  private let stackView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
  }
  
  private let firstTabButton = UIButton().then {
    $0.setTitle("제목", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.setTitleColor(.main, for: .selected)
  }
  
  private let secondTabButton = UIButton().then {
    $0.setTitle("모임이름", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.setTitleColor(.main, for: .selected)
  }
  
  private let thirdTabButton = UIButton().then {
    $0.setTitle("제목+글", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.setTitleColor(.main, for: .selected)
  }
  
  private let bottomLine = UIView().then {
    $0.backgroundColor = .mediumGray
  }
  
  private let indicator = UIView().then {
    $0.backgroundColor = .main
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [firstTabButton, secondTabButton, thirdTabButton].forEach { stackView.addArrangedSubview($0) }
    addSubview(stackView)
    stackView.addSubview(bottomLine)
    bottomLine.addSubview(indicator)
    
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    bottomLine.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.leading.trailing.bottom.equalToSuperview()
    }
    
    indicator.snp.makeConstraints {
      $0.height.equalTo(1)
    }
  }
}
