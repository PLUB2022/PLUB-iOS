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
  func didTappedTopBar(which: IndexPath)
}

class SearchOutputHeaderView: UIView {
  
  private let disposeBag = DisposeBag()
  private let tabModel = [
    "제목",
    "모임이름",
    "제목+내용"
  ]
  
  weak var delegate: SearchOutputHeaderViewDelegate?
  
  var filterChanged: SortType = .popular {
    didSet {
      sortButton.sortChanged = filterChanged
    }
  }
  
  private lazy var topTabCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.scrollDirection = .horizontal
    $0.minimumInteritemSpacing = 0
    $0.minimumLineSpacing = 0
  }).then {
    $0.backgroundColor = .background
    $0.isScrollEnabled = false
    $0.register(TopTabCollectionViewCell.self, forCellWithReuseIdentifier: TopTabCollectionViewCell.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.showsHorizontalScrollIndicator = false
  }
  
  private let highlightView = UIView().then {
    $0.backgroundColor = .main
  }
  
  private let sortButton = SortControl()
  
  private let interestListChartButton = ToggleButton(type: .chart)
  
  private let interesetListGridButton = ToggleButton(type: .grid)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
    setTabbar()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    interestListChartButton.isSelected = true
    [topTabCollectionView, highlightView, sortButton, interestListChartButton, interesetListGridButton].forEach { addSubview($0) }
    
    topTabCollectionView.snp.makeConstraints {
      $0.top.width.equalToSuperview()
      $0.height.equalTo(32)
    }
    
    highlightView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.leading.equalTo(topTabCollectionView.snp.leading)
      $0.bottom.equalTo(topTabCollectionView.snp.bottom)
      $0.width.equalTo((Device.width - 20) / 3)
    }
    
    interesetListGridButton.snp.makeConstraints {
      $0.trailing.equalToSuperview()
      $0.top.equalTo(topTabCollectionView.snp.bottom)
    }
    
    interestListChartButton.snp.makeConstraints {
      $0.top.equalTo(topTabCollectionView.snp.bottom)
      $0.trailing.equalTo(interesetListGridButton.snp.leading)
    }
    
    sortButton.snp.makeConstraints {
      $0.leading.equalToSuperview()
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
  
  private func setTabbar() {
    let firstIndexPath = IndexPath(item: 0, section: 0)
    topTabCollectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .right)
  }
}

extension SearchOutputHeaderView: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return tabModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopTabCollectionViewCell.identifier, for: indexPath) as? TopTabCollectionViewCell ?? TopTabCollectionViewCell()
    cell.configureUI(with: tabModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath) as? TopTabCollectionViewCell ?? TopTabCollectionViewCell()
    
    delegate?.didTappedTopBar(which: indexPath)
    
    UIView.animate(withDuration: 0.3) {
      self.highlightView.snp.remakeConstraints {
        $0.height.equalTo(1)
        $0.bottom.equalTo(cell.snp.bottom)
        $0.leading.equalTo(cell.snp.leading)
        $0.trailing.equalTo(cell.snp.trailing)
      }
      self.layoutIfNeeded()
    }
  }
}


extension SearchOutputHeaderView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.height)
  }
}
