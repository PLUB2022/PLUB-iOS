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
    $0.text = "8번째 멤버와 함께갑니다!"
  }
  
  private let contentLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .caption
  }
  
  private let heartImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.image = UIImage(named: "heartFilled")
  }
  
  private let heartCountLabel = UILabel().then {
    $0.textColor = .deepGray
    $0.font = .overLine
    $0.text = "3"
  }
  
  private let commentImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.image = UIImage(named: "commentDots")
  }
  
  private let commentCountLabel = UILabel().then {
    $0.textColor = .deepGray
    $0.font = .overLine
    $0.text = "3"
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [heartImageView, heartCountLabel, commentImageView, commentCountLabel].forEach { likeCommentStackView.addArrangedSubview($0) }
    [titleLabel, likeCommentStackView].forEach { contentView.addSubview($0) }
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(12)
      $0.leading.equalToSuperview().inset(16)
    }
    
    likeCommentStackView.snp.makeConstraints {
      $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing)
      $0.top.equalToSuperview().inset(12)
      $0.trailing.equalToSuperview().inset(16)
    }
  }
}
