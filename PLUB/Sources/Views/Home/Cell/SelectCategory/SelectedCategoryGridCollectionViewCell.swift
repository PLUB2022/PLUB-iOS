//
//  InterestListGridCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit

import RxSwift

protocol SelectedCategoryGridCollectionViewCellDelegate: AnyObject {
  func didTappedGridBookmarkButton(plubbingID: Int)
  func updateBookmarkState(isBookmarked: Bool, cell: UICollectionViewCell)
}

final class SelectedCategoryGridCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "SelectedCategoryGridCollectionViewCell"
  private let disposeBag = DisposeBag()
  private var plubbingID: Int?
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
  
  private lazy var gradientLayer = CAGradientLayer().then {
    $0.locations = [0, 1]
    $0.startPoint = CGPoint(x: 0.25, y: 0.5)
    $0.endPoint = CGPoint(x: 0.75, y: 0.5)
    $0.transform = CATransform3DMakeAffineTransform(
      CGAffineTransform(
        a: 0,
        b: 0.75,
        c: -0.75,
        d: 0.01,
        tx: 0.87,
        ty: -0.06)
    )
    $0.bounds = contentView.bounds.insetBy(
      dx: -0.5*contentView.bounds.size.width,
      dy: -1*contentView.bounds.size.height
    )
    
    $0.position = contentView.center
    let colors: [CGColor] = [
      UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
      UIColor(red: 0, green: 0, blue: 0, alpha: 0.84).cgColor
    ]
    $0.colors = colors
  }
  
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
  
  private func configureUI() {
    contentView.layer.cornerRadius = 10
    contentView.layer.masksToBounds = true
    
    backgroundImageView.layer.addSublayer(gradientLayer)
    contentView.addSubview(backgroundImageView)
    
    [titleLabel, descriptionLabel, categoryInfoListView, bookmarkButton].forEach { backgroundImageView.addSubview($0) }
    
    backgroundImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    categoryInfoListView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(10)
      $0.bottom.equalToSuperview().offset(-10)
      $0.width.lessThanOrEqualTo(Device.width - 32 - 20)
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
        owner.delegate?.didTappedGridBookmarkButton(plubbingID: plubbingID)
        owner.delegate?.updateBookmarkState(isBookmarked: true, cell: owner)
      })
      .disposed(by: disposeBag)
    
    bookmarkButton.buttonUnTapObservable
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        guard let plubbingID = owner.plubbingID else { return }
        owner.delegate?.didTappedGridBookmarkButton(plubbingID: plubbingID)
        owner.delegate?.updateBookmarkState(isBookmarked: false, cell: owner)
      })
      .disposed(by: disposeBag)
  }
  
  func configureUI(with model: SelectedCategoryCollectionViewCellModel) {
    let url = URL(string: model.mainImage ?? "")
    backgroundImageView.kf.setImage(with: url)
    bookmarkButton.isSelected = model.isBookmarked
    titleLabel.text = model.title
    descriptionLabel.text = model.introduce
    categoryInfoListView.configureUI(with: model.selectedCategoryInfoModel)
    plubbingID = model.plubbingID
  }
}
