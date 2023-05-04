//
//  TodoCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/28.
//

import UIKit

import Kingfisher
import RxSwift
import SnapKit
import Then

protocol TodoCollectionViewCellDelegate: AnyObject {
  func didTappedMoreButton()
  func didTappedLikeButton(isLiked: Bool)
  func didTappedTodo()
}

struct TodoCollectionViewCellModel {
  let date: String
  let profileImageString: String?
  let totalLikes: Int
  let isLike: Bool
  let isAuthor: Bool
  let checkTodoViewModels: [CheckTodoViewModel]
  
  init(response: InquireAllTodoTimelineResponse) {
    date = response.date
    profileImageString = response.accountInfo?.profileImage
    totalLikes = response.totalLikes
    isLike = response.isLike
    isAuthor = response.isAuthor
    checkTodoViewModels = response.todoList.map { CheckTodoViewModel(todo: $0.content, isChecked: $0.isChecked) }
  }
}

final class TodoCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "TodoCollectionViewCell"
  private let disposeBag = DisposeBag()
  weak var delegate: TodoCollectionViewCellDelegate?
  
  private let profileImageView = UIImageView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 12
    $0.contentMode = .scaleAspectFill
  }
  
  private let likeButton = ToggleButton(type: .like)
  
  private let likeCountLabel = UILabel().then {
    $0.textColor = .mediumGray
    $0.font = .caption2
  }
  
  private let listContainerView = UIStackView().then {
    $0.backgroundColor = .white
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 8, left: 8, bottom: 8, right: 8)
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
  
  override func prepareForReuse() {
    super.prepareForReuse()
    likeCountLabel.text = nil
    profileImageView.image = nil
    likeButton.isSelected = false
    listContainerView.subviews.forEach { $0.removeFromSuperview() }
  }
  
  private func configureUI() {
    contentView.backgroundColor = .background
    [profileImageView, likeButton, likeCountLabel, listContainerView, moreButton].forEach { contentView.addSubview($0) }
    
    profileImageView.snp.makeConstraints {
      $0.top.leading.equalToSuperview().inset(8)
      $0.size.equalTo(24)
    }
    
    likeButton.snp.makeConstraints {
      $0.top.equalTo(profileImageView.snp.bottom).offset(8)
      $0.leading.equalToSuperview().inset(3)
      $0.bottom.lessThanOrEqualToSuperview()
      $0.size.equalTo(16)
    }
    
    likeCountLabel.snp.makeConstraints {
      $0.centerY.equalTo(likeButton)
      $0.leading.equalTo(likeButton.snp.trailing).offset(2)
    }
    
    listContainerView.snp.makeConstraints {
      $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
      $0.bottom.lessThanOrEqualToSuperview()
      $0.top.trailing.equalToSuperview()
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
  
  func configureUI(with model: TodoCollectionViewCellModel) {
    guard let profileImageString = model.profileImageString,
          let url = URL(string: profileImageString) else { return }
    profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "userDefaultImage"))
    likeCountLabel.text = "\(model.totalLikes)"
    likeButton.isSelected = model.isLike
    model.checkTodoViewModels.forEach { checkTodoVieModel in
      let todoView = CheckTodoView()
      todoView.delegate = self
      todoView.configureUI(with: checkTodoVieModel)
      listContainerView.addArrangedSubview(todoView)
    }
  }
}

extension TodoCollectionViewCell {
  static func estimatedCommentCellSize(_ targetSize: CGSize, model: TodoCollectionViewCellModel) -> CGSize {
    let view = TodoCollectionViewCell()
    view.configureUI(with: model)
    return view.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
  }
}

extension TodoCollectionViewCell: CheckTodoViewDelegate {
  func didTappedCheckboxButton() {
    delegate?.didTappedTodo()
  }
}
