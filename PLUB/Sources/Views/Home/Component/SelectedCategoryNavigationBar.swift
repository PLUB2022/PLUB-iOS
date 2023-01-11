//
//  InterestListNavigationBar.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit

protocol SelectedCategoryNavigationBarDelegate: AnyObject {
  func didTappedBackButton()
  func didTappedSearchButton()
}

final class SelectedCategoryNavigationBar: UIView {
  
  public weak var delegate: SelectedCategoryNavigationBarDelegate?
  
  private let backButton = UIButton().then {
    $0.setImage(UIImage(named: "Back"), for: .normal)
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 30, weight: .bold)
    $0.textAlignment = .left
    $0.numberOfLines = 0
  }
  
  private let searchButton = UIButton().then {
    $0.setImage(UIImage(named: "Union"), for: .normal)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: -Configure
  private func configureUI() {
    backButton.addTarget(self, action: #selector(didTappedBackButton), for: .touchUpInside)
    searchButton.addTarget(self, action: #selector(didTappedSearchButton), for: .touchUpInside)
    
    [backButton, titleLabel, searchButton].forEach { addSubview($0) }
    backButton.snp.makeConstraints {
      $0.left.centerY.equalToSuperview()
    }
    titleLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.left.equalTo(backButton.snp.right)
    }
    searchButton.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.right.equalToSuperview().offset(-20)
    }
  }
  
  public func configureUI(with model: String) {
    titleLabel.text = model
  }
  
  // MARK: -Action
  @objc private func didTappedBackButton() {
    delegate?.didTappedBackButton()
  }
  
  @objc private func didTappedSearchButton() {
    delegate?.didTappedSearchButton()
  }
}
