//
//  InterestListGridCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit

import RxSwift

final class SelectedCategoryGridCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "SelectedCategoryGridCollectionViewCell"
  private let disposeBag = DisposeBag()
  
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
  
  private let categoryInfoListView = CategoryInfoListView(categoryAlignment: .vertical, categoryListType: .all)
  
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
//    bookmarkButton.setImage(UIImage(named: "bookmarkInActivated"), for: .normal)
    print("북마크 = \(model.isBookmarked)")
    bookmarkButton.isSelected = model.isBookmarked
    titleLabel.text = model.title
    descriptionLabel.text = model.introduce
    categoryInfoListView.configureUI(with: model.selectedCategoryInfoModel)
  }
}
