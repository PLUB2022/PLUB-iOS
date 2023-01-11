//
//  InterestListChartCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit
import SnapKit
import Then

struct SelectedCategoryCollectionViewCellModel { // 차트, 그리드일때 둘 다 동일한 모델
  let title: String
  let description: String
  let selectedCategoryInfoViewModel: SelectedCategoryInfoViewModel
}

class SelectedCategoryChartCollectionViewCell: UICollectionViewCell {
  static let identifier = "SelectedCategoryChartCollectionViewCell"
  
  private let titleLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 25, weight: .bold)
    $0.numberOfLines = 0
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
  
  private let selectedCategoryInfoView = SelectedCategoryInfoView(selectedCategoryInfoViewType: .horizontal)
  
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
    selectedCategoryInfoView.backgroundColor = nil
  }
  
  private func configureUI() {
    contentView.backgroundColor = .black
    _ = [titleLabel, descriptionLabel, seperatorView, selectedCategoryInfoView].map{ contentView.addSubview($0) }
    titleLabel.snp.makeConstraints {
      $0.top.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
    }
    
    selectedCategoryInfoView.snp.makeConstraints {
      $0.bottom.equalToSuperview().offset(-20)
      $0.left.right.equalTo(titleLabel)
      $0.height.equalTo(20)
    }
    
    seperatorView.snp.makeConstraints {
      $0.left.equalTo(selectedCategoryInfoView.snp.left)
      $0.bottom.equalTo(selectedCategoryInfoView.snp.top).offset(-10)
      $0.width.equalTo(200)
      $0.height.equalTo(1)
    }
    
    descriptionLabel.snp.makeConstraints {
      $0.left.equalTo(seperatorView.snp.left)
      $0.right.equalTo(titleLabel.snp.right)
      $0.bottom.equalTo(seperatorView.snp.top).offset(-10)
    }
  }
  
  public func configureUI(with model: SelectedCategoryCollectionViewCellModel) {
    titleLabel.text = model.title
    descriptionLabel.text = model.description
    seperatorView.backgroundColor = .white
    selectedCategoryInfoView.configureUI(with: model.selectedCategoryInfoViewModel)
  }
}
