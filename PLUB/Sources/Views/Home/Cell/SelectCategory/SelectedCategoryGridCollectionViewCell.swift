//
//  InterestListGridCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit

import RxSwift

protocol SelectedCategoryGridCollectionViewCellDelegate: AnyObject {
  func didTappedGridBookmarkButton(plubbingID: String)
  func updateBookmarkState(isBookmarked: Bool, cell: UICollectionViewCell)
}

final class SelectedCategoryGridCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "SelectedCategoryGridCollectionViewCell"
  private let disposeBag = DisposeBag()
  private var plubbingID: String?
  weak var delegate: SelectedCategoryGridCollectionViewCellDelegate?
  
  private let backgroundImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
  }
  
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
    backgroundImageView.image = nil
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
    
    contentView.addSubview(backgroundImageView)
    [titleLabel, descriptionLabel, categoryInfoListView, bookmarkButton].forEach { backgroundImageView.addSubview($0) }
    
    backgroundImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    categoryInfoListView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(10)
      $0.bottom.equalToSuperview().offset(-10)
    }
    
    descriptionLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(10)
      $0.bottom.equalTo(categoryInfoListView.snp.top).offset(-10)
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.trailing.equalTo(descriptionLabel)
      $0.bottom.equalTo(descriptionLabel.snp.top).offset(-10)
    }
    
    bookmarkButton.snp.makeConstraints {
      $0.top.trailing.equalToSuperview().inset(16)
      $0.width.height.equalTo(32)
    }
  }
  
  private func bind() {
    bookmarkButton.buttonTapObservable
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        guard let plubbingID = owner.plubbingID else { return }
        owner.delegate?.didTappedGridBookmarkButton(plubbingID: "\(plubbingID)")
        owner.delegate?.updateBookmarkState(isBookmarked: true, cell: owner)
      })
      .disposed(by: disposeBag)
    
    bookmarkButton.buttonUnTapObservable
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        guard let plubbingID = owner.plubbingID else { return }
        owner.delegate?.didTappedGridBookmarkButton(plubbingID: "\(plubbingID)")
        owner.delegate?.updateBookmarkState(isBookmarked: false, cell: owner)
      })
      .disposed(by: disposeBag)
  }
  
  public func configureUI(with model: SelectedCategoryCollectionViewCellModel) {
    guard let mainImage = model.mainImage,
          let url = URL(string: mainImage) else { return }
    backgroundImageView.kf.setImage(with: url)
    bookmarkButton.isSelected = model.isBookmarked
    titleLabel.text = model.title
    descriptionLabel.text = model.introduce
    categoryInfoListView.configureUI(with: model.selectedCategoryInfoModel)
    plubbingID = model.plubbingID
  }
}
