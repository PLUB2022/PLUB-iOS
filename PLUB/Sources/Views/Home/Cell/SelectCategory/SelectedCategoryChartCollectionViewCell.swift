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
  let plubbingID: Int
  let name: String
  let title: String
  let mainImage: String?
  let introduce: String
  var isBookmarked: Bool
  let selectedCategoryInfoModel: CategoryInfoListModel
}

protocol SelectedCategoryChartCollectionViewCellDelegate: AnyObject {
  func didTappedChartBookmarkButton(plubbingID: Int)
  func updateBookmarkState(isBookmarked: Bool, cell: UICollectionViewCell)
}

final class SelectedCategoryChartCollectionViewCell: UICollectionViewCell {
  static let identifier = "SelectedCategoryChartCollectionViewCell"
  weak var delegate: SelectedCategoryChartCollectionViewCellDelegate?
  
  private let disposeBag = DisposeBag()
  private var plubbingID: Int?
  
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
  
  private let categoryInfoListView = CategoryInfoListView(categoryAlignment: .horizontal, categoryListType: .all)
  
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
      $0.size.equalTo(32)
    }
    
  }
  
  private func bind() {
    bookmarkButton.buttonTapObservable
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        guard let plubbingID = owner.plubbingID else { return }
        owner.delegate?.didTappedChartBookmarkButton(plubbingID: plubbingID)
        owner.delegate?.updateBookmarkState(isBookmarked: true, cell: owner)
      })
      .disposed(by: disposeBag)
    
    bookmarkButton.buttonUnTapObservable
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        guard let plubbingID = owner.plubbingID else { return }
        owner.delegate?.didTappedChartBookmarkButton(plubbingID: plubbingID)
        owner.delegate?.updateBookmarkState(isBookmarked: false, cell: owner)
      })
      .disposed(by: disposeBag)
  }
  
  public func configureUI(with model: SelectedCategoryCollectionViewCellModel) {
    let url = URL(string: model.mainImage ?? "")
    backgroundImageView.kf.setImage(with: url)
    titleLabel.text = model.title
    descriptionLabel.text = model.introduce
    categoryInfoListView.configureUI(with: model.selectedCategoryInfoModel)
    bookmarkButton.isSelected = model.isBookmarked
    plubbingID = model.plubbingID
  }
}
