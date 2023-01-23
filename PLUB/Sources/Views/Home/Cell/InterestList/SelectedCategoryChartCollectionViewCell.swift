//
//  InterestListChartCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit

import RxSwift
import SnapKit
import Then

struct SelectedCategoryCollectionViewCellModel { // 차트, 그리드일때 둘 다 동일한 모델
  let title: String
  let description: String
  let selectedCategoryInfoModel: CategoryInfoListModel
}

class SelectedCategoryChartCollectionViewCell: UICollectionViewCell {
  static let identifier = "SelectedCategoryChartCollectionViewCell"
  private var disposeBag = DisposeBag()
  
  private let titleLabel = UILabel().then {
    $0.font = .subtitle
    $0.numberOfLines = 0
    $0.textColor = .white
    $0.textAlignment = .left
    $0.sizeToFit()
  }
  
  private let descriptionLabel = UILabel().then {
    $0.font = .caption
    $0.numberOfLines = 1
    $0.lineBreakMode = .byTruncatingTail
    $0.textColor = .white
    $0.textAlignment = .left
  }
  
  private let bookmarkButton = ToggleButton(type: .bookmark)
  
  private let categoryInfoListView = CategoryInfoListView(categoryAlignment: .horizontal, categoryListType: .all)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    titleLabel.text = nil
    descriptionLabel.text = nil
    categoryInfoListView.backgroundColor = nil
    bookmarkButton.setImage(nil, for: .normal)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    categoryInfoListView.snp.makeConstraints {
      $0.width.lessThanOrEqualTo(self.frame.width - 20)
    }
  }
  
  private func configureUI() {
    contentView.backgroundColor = .orange
    contentView.layer.cornerRadius = 10
    contentView.layer.masksToBounds = true
    [titleLabel, descriptionLabel, categoryInfoListView, bookmarkButton].forEach { contentView.addSubview($0) }
    
    categoryInfoListView.snp.makeConstraints {
      $0.left.equalToSuperview().offset(10)
      $0.bottom.equalToSuperview().offset(-10)
    }
    
    descriptionLabel.snp.makeConstraints {
      $0.left.right.equalToSuperview().inset(10)
      $0.bottom.equalTo(categoryInfoListView.snp.top).offset(-10)
    }
    
    titleLabel.snp.makeConstraints {
      $0.left.right.equalTo(descriptionLabel)
      $0.bottom.equalTo(descriptionLabel.snp.top).offset(-10)
    }
    
    bookmarkButton.snp.makeConstraints {
      $0.top.right.equalToSuperview().inset(16)
      $0.width.height.equalTo(32)
    }
  }
  
  private func bind() {
    bookmarkButton.buttonTapObservable
      .subscribe(onNext: {
        
      })
      .disposed(by: disposeBag)
    
    bookmarkButton.buttonUnTapObservable
      .subscribe(onNext: {
        
      })
      .disposed(by: disposeBag)
  }
  
  public func configureUI(with model: SelectedCategoryCollectionViewCellModel) {
    titleLabel.text = model.title
    descriptionLabel.text = model.description
    categoryInfoListView.configureUI(with: model.selectedCategoryInfoModel)
    bookmarkButton.setImage(UIImage(named: "whiteBookmark"), for: .normal)
  }
}
