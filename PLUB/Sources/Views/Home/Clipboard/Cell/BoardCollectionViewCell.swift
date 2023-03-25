//
//  BoardCollectionViewCell.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/25.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class BoardCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "BoardsCollectionViewCell"
  
  // MARK: - Properties
  var feedID: Int?
  
  // MARK: - UI Components
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
    $0.text = "개나리"
    $0.textColor = .deepGray
  }
  
  private let dateLabel = UILabel().then {
    $0.font = .overLine
    $0.text = "| 2022. 08. 10."
    $0.textColor = .deepGray
  }
  
  // MARK: Detail Info
  
  private let likeCommentStackView = UIStackView().then {
    $0.alignment = .center
  }
  
  private let heartImageView = UIImageView(image: .init(named: "heartFilled"))
  private let heartCountLabel = UILabel().then {
    $0.font = .overLine
    $0.text = "3"
    $0.textColor = .deepGray
  }
  private let commentImageView = UIImageView(image: .init(named: "commentDots"))
  private let commentCountLabel = UILabel().then {
    $0.font = .overLine
    $0.text = "3"
    $0.textColor = .deepGray
  }
  
  // MARK: Content Info
  
  private let titleLabel = UILabel().then {
    $0.font = .subtitle
    $0.text = "안녕하세요. 반갑습니다. 게시판 제목입니다."
    $0.textColor = .black
  }
  
  private let contentLabel = UILabel().then {
    $0.numberOfLines = 2
    $0.font = .caption
    $0.text = "국가는 주택개발정책등을 통하여 모든 국민이 쾌적한 주거생활을 할 수 있도록 노력하여야 한다. 국가는 국민 모두의 생산 및 생활의 기반이 되는 국토의 효율적이고 균형있는 이용·개발과 보전을 위하여 법률이 정하는 바에 의하여 그에 관한 필요한 제한과 의무를 과할 수 있다. 모든 국민은 법률이 정하는 바에 의하여 공무담임권을 가진다. 모든 국민은 인간다운 생활을 할 권리를 가진다. 지방의회의 조직·권한·의원선거와 지방자치단체의 장의 선임방법 기타 지방자치단체의 조직과 운영에 관한 사항은 법률로 정한다. 이 헌법은 1988년 2월 25일부터 시행한다. 다만, 이 헌법을 시행하기 위하여 필요한 법률의 제정·개정과 이 헌법에 의한 대통령 및 국회의원의 선거 기타 이 헌법시행에 관한 준비는 이 헌법시행 전에 할 수 있다."
    $0.textColor = .black
  }
  
  // MARK: - Initializations
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configuration
  
  private func setupLayouts() {
    contentView.addSubview(wholeStackView)
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
    wholeStackView.snp.makeConstraints {
      $0.directionalVerticalEdges.equalToSuperview().inset(12)
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
    }
    
    profileImageView.snp.makeConstraints {
      $0.size.equalTo(24)
    }
  }
  
  private func setupStyles() {
    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 10
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
    if model.type != .photo {
      contentImageView.snp.remakeConstraints {
        $0.size.lessThanOrEqualTo(90)
      }
    } else {
      contentImageView.snp.removeConstraints()
    }
  }
}
