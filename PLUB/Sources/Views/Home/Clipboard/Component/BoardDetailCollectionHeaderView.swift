//
//  BoardDetailCollectionHeaderView.swift
//  PLUB
//
//  Created by 홍승현 on 2023/03/06.
//

import UIKit

import Kingfisher
import RxSwift
import RxCocoa
import SnapKit
import Then

protocol BoardDetailCollectionHeaderViewDelegate: AnyObject {
  func didTappedHeartButton()
  func didTappedSettingButton()
}

final class BoardDetailCollectionHeaderView: UICollectionReusableView {
  
  // MARK: - Properties
  
  static let identifier = "\(BoardDetailCollectionHeaderView.self)"
  
  private let disposeBag = DisposeBag()
  
  weak var delegate: BoardDetailCollectionHeaderViewDelegate?
  
  // MARK: - UI Components
  
  private let wholeStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private let headerStackView = UIStackView().then {
    $0.distribution = .equalCentering
    $0.alignment = .center
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
    $0.textColor = .black
  }
  
  private let dateLabel = UILabel().then {
    $0.font = .overLine
    $0.text = "| 2022. 08. 10."
    $0.textColor = .black
  }
  
  // MARK: Detail Info
  
  private let likeCommentStackView = UIStackView().then {
    $0.alignment = .center
    $0.spacing = 2
  }
  
  private let heartButton = UIButton().then {
    $0.setImage(.init(named: "heartFilled"), for: .normal)
  }
  
  private let heartCountLabel = UILabel().then {
    $0.font = .overLine
    $0.text = "3"
    $0.textColor = .deepGray
  }
  
  private let commentImageView = UIImageView(image: .init(named: "commentDots")?.withRenderingMode(.alwaysTemplate)).then {
    $0.tintColor = .deepGray
  }
  
  private let commentCountLabel = UILabel().then {
    $0.font = .overLine
    $0.text = "3"
    $0.textColor = .deepGray
  }
  
  private let settingButton = UIButton().then {
    $0.setImage(UIImage(named: "kebabMenu"), for: .normal)
  }
  
  // MARK: Content Info
  
  private let titleLabel = UILabel().then {
    $0.font = .subtitle
    $0.text = "안녕하세요. 반갑습니다. 게시판 제목입니다."
    $0.textColor = .black
    $0.numberOfLines = 0
  }
  
  private let contentImageView = UIImageView().then {
    $0.layer.cornerRadius = 10
    $0.clipsToBounds = true
    $0.contentMode = .scaleAspectFill
    $0.isHidden = true
  }
  
  private let contentLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = .body2
    $0.text = "국가는 주택개발정책등을 통하여 모든 국민이 쾌적한 주거생활을 할 수 있도록 노력하여야 한다. 국가는 국민 모두의 생산 및 생활의 기반이 되는 국토의 효율적이고 균형있는 이용·개발과 보전을 위하여 법률이 정하는 바에 의하여 그에 관한 필요한 제한과 의무를 과할 수 있다. 모든 국민은 법률이 정하는 바에 의하여 공무담임권을 가진다. 모든 국민은 인간다운 생활을 할 권리를 가진다. 지방의회의 조직·권한·의원선거와 지방자치단체의 장의 선임방법 기타 지방자치단체의 조직과 운영에 관한 사항은 법률로 정한다. 이 헌법은 1988년 2월 25일부터 시행한다. 다만, 이 헌법을 시행하기 위하여 필요한 법률의 제정·개정과 이 헌법에 의한 대통령 및 국회의원의 선거 기타 이 헌법시행에 관한 준비는 이 헌법시행 전에 할 수 있다."
    $0.textColor = .black
  }
  
  // MARK: Footer Info
  
  private let footerView = UIView().then {
    $0.backgroundColor = .background
  }
  
  private let footerStackView = UIStackView().then {
    $0.alignment = .center
  }
  
  private let commentImageViewFooter = UIImageView(image: .init(named: "commentDots")?.withRenderingMode(.alwaysTemplate)).then {
    $0.tintColor = .deepGray
  }
  
  private let commentLabel = UILabel().then {
    $0.text = "달린 댓글 3"
    $0.textColor = .deepGray
    $0.font = .overLine
  }
  
  // MARK: - Initializations
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
    setupConstraints()
    setupStyles()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  private func setupLayouts() {
    addSubview(wholeStackView)
    addSubview(footerView)
    footerView.addSubview(footerStackView)
    [headerStackView, titleLabel, contentImageView, contentLabel].forEach {
      wholeStackView.addArrangedSubview($0)
    }
    
    [boardsInfoStackView, likeCommentStackView].forEach {
      headerStackView.addArrangedSubview($0)
    }
    
    [profileImageView, authorLabel, dateLabel].forEach {
      boardsInfoStackView.addArrangedSubview($0)
    }
    
    [heartButton, heartCountLabel, commentImageView, commentCountLabel, settingButton].forEach {
      likeCommentStackView.addArrangedSubview($0)
    }
    
    [commentImageViewFooter, commentLabel].forEach {
      footerStackView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    wholeStackView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview().inset(16)
      $0.bottom.equalTo(footerView.snp.top).offset(-16)
    }
    
    footerView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(32)
    }
    
    [profileImageView, heartButton, settingButton, commentImageViewFooter].forEach {
      $0.snp.makeConstraints {
        $0.size.equalTo(Size.assetSize)
      }
    }
    
    contentImageView.snp.makeConstraints {
      $0.height.lessThanOrEqualTo(245)
    }
    
    footerStackView.snp.makeConstraints {
      $0.top.trailing.bottom.equalToSuperview()
      $0.leading.equalToSuperview().inset(16)
    }
    
    boardsInfoStackView.setCustomSpacing(8, after: profileImageView)
    wholeStackView.setCustomSpacing(24, after: headerStackView)
  }
  
  private func setupStyles() {
    backgroundColor = .white
  }
  
  private func bind() {
    heartButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedHeartButton()
      }
      .disposed(by: disposeBag)
    
    settingButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedSettingButton()
      }
      .disposed(by: disposeBag)
  }
  
  func configure(with model: BoardModel) {
    if let imageLink = model.authorProfileImageLink, imageLink.isEmpty == false {
      profileImageView.kf.setImage(with: URL(string: imageLink)!)
    } else {
      profileImageView.image = UIImage(named: "userDefaultImage")
    }
    authorLabel.text = model.author
    dateLabel.text = DateFormatter().then { $0.dateFormat = "yyyy. MM. dd." }.string(from: model.date)
    heartCountLabel.text = "\(model.likeCount)"
    commentCountLabel.text = "\(model.commentCount)"
    titleLabel.text = model.title
    contentLabel.text = model.content
    
    contentImageView.isHidden = model.imageLink == nil
    if let contentImageLink = model.imageLink, contentImageLink.isEmpty == false {
      contentImageView.kf.setImage(with: URL(string: contentImageLink)!)
    }
    commentLabel.text = "달린 댓글 \(model.commentCount)"
  }
}

// MARK: - Constants

extension BoardDetailCollectionHeaderView {
  enum Size {
    static let assetSize = 24
  }
}
