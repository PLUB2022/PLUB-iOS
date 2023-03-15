//
//  BoardSystemCollectionViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/14.
//

import UIKit

import SnapKit
import Then

final class BoardSystemCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "BoardSystemCollectionViewCell"
  
  private let likeCommentStackView = UIStackView().then {
    $0.axis = .horizontal
  }
  
  private let titleLabel = UILabel().then {
    $0.textColor = .main
    $0.font = .subtitle
    $0.numberOfLines = 0
  }
  
  private let contentLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .caption
    $0.numberOfLines = 2
    $0.lineBreakMode = .byTruncatingTail
  }
  
  private let heartImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.image = UIImage(named: "heartFilled")
  }
  
  private let heartCountLabel = UILabel().then {
    $0.textColor = .deepGray
    $0.font = .overLine
  }
  
  private let commentImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.image = UIImage(named: "commentDots")
  }
  
  private let commentCountLabel = UILabel().then {
    $0.textColor = .deepGray
    $0.font = .overLine
  }
  
  private let dateLabel = UILabel().then {
    $0.font = .overLine
    $0.textColor = .deepGray
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    titleLabel.text = nil
    contentLabel.text = nil
    heartCountLabel.text = nil
    commentCountLabel.text = nil
    dateLabel.text = nil
  }
  
  private func configureUI() {
    contentView.backgroundColor = .white
    contentView.layer.masksToBounds = true
    contentView.layer.cornerRadius = 10
  
    [heartImageView, heartCountLabel, commentImageView, commentCountLabel].forEach { likeCommentStackView.addArrangedSubview($0) }
    [titleLabel, likeCommentStackView, contentLabel, dateLabel].forEach { contentView.addSubview($0) }
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(12)
      $0.leading.equalToSuperview().inset(16)
    }
    
    [heartImageView, commentImageView].forEach {
      $0.snp.makeConstraints {
        $0.size.equalTo(24)
      }
    }
    
    likeCommentStackView.snp.makeConstraints {
      $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing)
      $0.top.equalToSuperview().inset(12)
      $0.trailing.equalToSuperview().inset(16)
    }
    
    contentLabel.snp.makeConstraints {
      $0.leading.equalTo(titleLabel)
      $0.top.equalTo(titleLabel.snp.bottom).offset(8)
      $0.trailing.lessThanOrEqualToSuperview().inset(16)
    }
    
    dateLabel.snp.makeConstraints {
      $0.trailing.equalTo(likeCommentStackView)
      $0.bottom.equalToSuperview().inset(13.81)
    }
  }
  
  public func configureUI(with model: BoardModel) {
    guard let content = model.content else { return }
    titleLabel.text = model.title
    contentLabel.text = content + "\n 멤버들과 함께 환영인사를 나눠보세요!"
    heartCountLabel.text = "\(model.likeCount)"
    commentCountLabel.text = "\(model.commentCount)"
    dateLabel.text = model.date.toString()
  }
}
