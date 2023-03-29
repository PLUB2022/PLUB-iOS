//
//  TodoCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/28.
//

import UIKit

import RxSwift
import SnapKit
import Then

protocol TodoCollectionViewCellDelegate: AnyObject {
  func didTappedMoreButton()
  func didTappedLikeButton(isLiked: Bool)
}

final class TodoCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "TodoCollectionViewCell"
  private let disposeBag = DisposeBag()
  weak var delegate: TodoCollectionViewCellDelegate?
  
  private let profileImageView = UIImageView().then {
    $0.image = UIImage(systemName: "person.fill")
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 12
  }
  
  private let likeButton = ToggleButton(type: .like)
  
  private let likeCountLabel = UILabel().then {
    $0.textColor = .mediumGray
    $0.font = .caption2
    $0.text = "0"
  }
  
  private let listContainerView = UIStackView().then {
    $0.backgroundColor = .white
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.axis = .vertical
  }
  
  private let moreButton = UIButton().then {
    $0.setImage(UIImage(named: "verticalEllipsisBlack"), for: .normal)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.backgroundColor = .background
    [profileImageView, likeButton, likeCountLabel, listContainerView, moreButton].forEach { contentView.addSubview($0) }
    
    profileImageView.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
      $0.size.equalTo(24)
    }
    
    likeButton.snp.makeConstraints {
      $0.top.equalTo(profileImageView.snp.bottom).offset(10.67)
      $0.trailing.equalTo(profileImageView.snp.centerX).offset(-1)
      $0.size.equalTo(16)
    }
    
    likeCountLabel.snp.makeConstraints {
      $0.top.equalTo(likeButton)
      $0.leading.equalTo(likeButton.snp.trailing).offset(2)
    }
    
    listContainerView.snp.makeConstraints {
      $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
      $0.directionalVerticalEdges.trailing.equalToSuperview()
    }
    
    moreButton.snp.makeConstraints {
      $0.size.equalTo(32)
      $0.top.trailing.equalToSuperview().inset(8)
    }
  }
  
  private func bind() {
    moreButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedMoreButton()
      }
      .disposed(by: disposeBag)
    
    likeButton.buttonTapObservable
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedLikeButton(isLiked: true)
      }
      .disposed(by: disposeBag)
    
    likeButton.buttonUnTapObservable
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedLikeButton(isLiked: false)
      }
      .disposed(by: disposeBag)
  }
  
  public func configureUI(with model: String) {
    for _ in 0...7 {
      let label = CheckTodoView()
//      label.text = "이건준이에용"
      listContainerView.addArrangedSubview(label)
    }
  }
}

extension TodoCollectionViewCell {
  static func estimatedCommentCellSize(_ targetSize: CGSize, model: String) -> CGSize {
    let view = TodoCollectionViewCell()
    view.configureUI(with: model)
    return view.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
  }
}
