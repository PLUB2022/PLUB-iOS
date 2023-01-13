//
//  InterestListFilterHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit

protocol SelectedCategoryFilterHeaderViewDelegate: AnyObject {
  func didTappedInterestListFilterButton()
  func didTappedInterestListChartButton()
  func didTappedInterestListGridButton()
}

class SelectedCategoryFilterHeaderView: UICollectionReusableView {
  static let identifier = "InterestListFilterHeaderView"
  
  public weak var delegate: SelectedCategoryFilterHeaderViewDelegate?
  
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
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    interestListFilterButton.addTarget(self, action: #selector(didTappedInterestListFilterButton), for: .touchUpInside)
    interestListChartButton.addTarget(self, action: #selector(didTappedInterestListChartButton), for: .touchUpInside)
    interesetListGridButton.addTarget(self, action: #selector(didTappedInterestListGridButton), for: .touchUpInside)
    
    [interestListFilterLabel, interestListFilterButton, interestListChartButton, interesetListGridButton].forEach { addSubview($0) }
    interestListFilterLabel.snp.makeConstraints {
      $0.centerY.left.equalToSuperview()
    }
    
    interestListFilterButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.left.equalTo(interestListFilterLabel.snp.right)
    }
    
    interesetListGridButton.snp.makeConstraints {
      $0.centerY.right.equalToSuperview()
    }
    
    interestListChartButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.right.equalTo(interesetListGridButton.snp.left)
    }
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
