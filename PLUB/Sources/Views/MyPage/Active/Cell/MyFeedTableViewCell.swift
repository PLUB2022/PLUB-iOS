//
//  MyFeedTableViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/05/07.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class MyFeedTableViewCell: UITableViewCell {
  
  static let identifier = "MyFeedTableViewCell"
  
  // MARK: - Properties
  
  var feedID: Int?
  
  // MARK: - UI Components
  
  private let backView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 10
  }
  
  private let wholeStackView = UIStackView().then {
    $0.alignment = .top
    $0.spacing = 8
  }
  
  private let containerStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private let headerStackView = UIStackView().then {
    $0.distribution = .equalCentering
    $0.alignment = .center
  }
  
  private let contentImageView = UIImageView().then {
    $0.layer.cornerRadius = 8
    $0.clipsToBounds = true
    $0.contentMode = .scaleAspectFill
  }
  
  // MARK: Boards Info
  
  private let boardsInfoStackView = UIStackView().then {
    $0.alignment = .center
    $0.spacing = 4
  }
  
  private let profileImageView = UIImageView(image: .init(named: "userDefaultImage")).then {
    $0.contentMode = .scaleAspectFit
    $0.layer.cornerRadius = 12
    $0.clipsToBounds = true
  }
  
  private let authorLabel = UILabel().then {
    $0.font = .caption2
    $0.textColor = .deepGray
  }
  
  private let dateLabel = UILabel().then {
    $0.font = .overLine
    $0.textColor = .deepGray
  }
  
  // MARK: Detail Info
  
  private let likeCommentStackView = UIStackView().then {
    $0.alignment = .center
  }
  
  private let heartImageView = UIImageView(image: .init(named: "heartFilled"))
  private let heartCountLabel = UILabel().then {
    $0.font = .overLine
    $0.textColor = .deepGray
  }
  private let commentImageView = UIImageView(image: .init(named: "commentDots"))
  private let commentCountLabel = UILabel().then {
    $0.font = .overLine
    $0.textColor = .deepGray
  }
  
  // MARK: Content Info
  
  private let titleLabel = UILabel().then {
    $0.font = .subtitle
    $0.textColor = .black
  }
  
  private let contentLabel = UILabel().then {
    $0.numberOfLines = 2
    $0.font = .caption
    $0.textColor = .black
  }
  
  // MARK: - Initializations
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configuration
  
  private func setupLayouts() {
    contentView.addSubview(backView)
    backView.addSubview(wholeStackView)
    wholeStackView.addArrangedSubview(containerStackView)
    wholeStackView.addArrangedSubview(contentImageView)
    
    [headerStackView, titleLabel, contentLabel].forEach {
      containerStackView.addArrangedSubview($0)
    }
    
    headerStackView.addArrangedSubview(boardsInfoStackView)
    headerStackView.addArrangedSubview(likeCommentStackView)
    
    [profileImageView, authorLabel, dateLabel].forEach {
      boardsInfoStackView.addArrangedSubview($0)
    }
    
    [heartImageView, heartCountLabel, commentImageView, commentCountLabel].forEach {
      likeCommentStackView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    backView.snp.makeConstraints {
      $0.directionalVerticalEdges.equalToSuperview().inset(4)
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
    }
    
    wholeStackView.snp.makeConstraints {
      $0.directionalVerticalEdges.equalToSuperview().inset(12)
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
    }
    
    profileImageView.snp.makeConstraints {
      $0.size.equalTo(24)
    }
  }
  
  private func setupStyles() {
    backgroundColor = .background
    selectionStyle = .none
  }
  
  func configure(with model: BoardModel) {
    feedID = model.feedID
    if let profileImageLink = model.authorProfileImageLink {
      profileImageView.kf.setImage(with: URL(string: profileImageLink))
    }
    authorLabel.text = model.author
    dateLabel.text = DateFormatter().then { $0.dateFormat = "| yyyy. MM. dd" }.string(from: model.date)
    heartCountLabel.text = String(model.likeCount)
    commentCountLabel.text = String(model.commentCount)
    
    titleLabel.text = model.title
    contentLabel.text = model.content
    if let contentImageLink = model.imageLink {
      contentImageView.kf.setImage(with: URL(string: contentImageLink))
    }
    
    // change stackview's axis
    wholeStackView.axis = model.type == .photoAndText ? .horizontal : .vertical
    wholeStackView.alignment = model.type == .photoAndText ? .top : .fill
    
    // change constraints according to `model.type`
    switch model.type {
    case .text, .photoAndText:
      contentImageView.snp.remakeConstraints {
        $0.size.lessThanOrEqualTo(90)
      }
    case .photo:
      contentImageView.snp.remakeConstraints {
        $0.size.equalTo(222)
      }
    }
  }
}
