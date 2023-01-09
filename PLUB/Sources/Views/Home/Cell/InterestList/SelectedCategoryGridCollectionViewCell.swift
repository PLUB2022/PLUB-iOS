//
//  InterestListGridCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit

class SelectedCategoryGridCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "SelectedCategoryGridCollectionViewCell"
  
  private let titleLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 25, weight: .bold)
    $0.numberOfLines = 1
    $0.lineBreakMode = .byTruncatingTail
    $0.textColor = .white
    $0.textAlignment = .left
  }
  
  private let descriptionLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 15, weight: .regular)
    $0.numberOfLines = 1
    $0.lineBreakMode = .byTruncatingTail
    $0.textColor = .white
    $0.textAlignment = .left
  }
  
  private let seperatorView = UIView()
  
  private let categoryInfoListView = CategoryInfoListView(categoryInfoListViewType: .vertical)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.layer.cornerRadius = 10
    contentView.layer.masksToBounds = true
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    titleLabel.text = nil
    descriptionLabel.text = nil
    seperatorView.backgroundColor = nil
    categoryInfoListView.backgroundColor = nil
  }
  
  private func configureUI() {
    contentView.backgroundColor = .black
    _ = [titleLabel, descriptionLabel, seperatorView, categoryInfoListView].map{ contentView.addSubview($0) }
    categoryInfoListView.snp.makeConstraints {
      $0.left.equalToSuperview().offset(10)
      $0.right.bottom.equalToSuperview().offset(-10)
      $0.height.equalTo(100)
    }
    
    seperatorView.snp.makeConstraints {
      $0.left.right.equalTo(categoryInfoListView)
      $0.bottom.equalTo(categoryInfoListView.snp.top).offset(-10)
    }
    
    descriptionLabel.snp.makeConstraints {
      $0.left.right.equalTo(seperatorView)
      $0.bottom.equalTo(seperatorView.snp.top).offset(-10)
    }
    
    titleLabel.snp.makeConstraints {
      $0.left.right.equalTo(seperatorView)
      $0.bottom.equalTo(descriptionLabel.snp.top).offset(-10)
    }
  }
  
  public func configureUI(with model: SelectedCategoryCollectionViewCellModel) {
    titleLabel.text = model.title
    descriptionLabel.text = model.description
    seperatorView.backgroundColor = .white
    categoryInfoListView.configureUI(with: model.selectedCategoryInfoViewModel)
  }
}
