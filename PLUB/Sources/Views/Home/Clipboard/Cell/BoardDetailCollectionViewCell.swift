//
//  BoardDetailCollectionViewCell.swift
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

protocol BoardDetailCollectionViewCellDelegate: AnyObject {
  func didTappedReplyButton(commentID: Int)
  func didTappedOptionButton(commentID: Int)
}

final class BoardDetailCollectionViewCell: UICollectionViewCell {
  
  // MARK: - Properties
  
  static let identifier = "\(BoardDetailCollectionViewCell.self)"
  
  weak var delegate: BoardDetailCollectionViewCellDelegate?
  
  private var commentID = 0
  
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private let wholeStackView = UIStackView().then {
    $0.alignment = .top
    $0.spacing = 8
  }
  
  private let replyImageView = UIImageView(image: .init(named: "fluentArrowReply")).then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let profileImageView = UIImageView(image: .init(named: "userDefaultImage")).then {
    $0.contentMode = .scaleAspectFit
    $0.layer.cornerRadius = 12
    $0.clipsToBounds = true
  }
  
  // MARK: Content Info
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
  }
  
  private let headerStackView = UIStackView().then {
    $0.alignment = .top
  }
  
  private let authorStackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .leading
    $0.spacing = 2
  }
  
  private let authorInformationStackView = UIStackView().then {
    $0.alignment = .center
    $0.distribution = .equalCentering
    $0.spacing = 4
  }
  
  private let footerStackView = UIStackView().then {
    $0.spacing = 4
    $0.alignment = .center
  }
  
  private let repliedAuthorLabel = UILabel().then {
    $0.text = "뭐시기 님에게 쓴 답글"
    $0.textColor = .deepGray
    $0.font = .overLine
  }
  
  private let authorLabel = UILabel().then {
    $0.text = "작성자"
    $0.textColor = .black
    $0.font = .body1
  }
  
  private let authorIndicationView = UIView().then {
    $0.backgroundColor = .subMain
    $0.layer.cornerRadius = 6
  }
  
  private let authorIndicationLabel = UILabel().then {
    $0.text = "글쓴이"
    $0.textColor = .main
    $0.font = .appFont(family: .pretendard(option: .semiBold), size: 10)
  }
  
  private let settingButton = UIButton().then {
    $0.setImage(.init(named: "meatballMenu"), for: .normal)
  }
  
  private let commentLabel = UILabel().then {
    $0.font = .caption
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.text = "국가는 주택개발정책등을 통하여 모든 국민이 쾌적한 주거생활을 할 수 있도록 노력하여야 한다. 국가는 국민 모두의 생산 및 생활의 기반이 되는 국토의 효율적이고 균형있는 이용·개발과 보전을 위하여 법률이 정하는 바에 의하여 그에 관한 필요한 제한과 의무를 과할 수 있다. 모든 국민은 법률이 정하는 바에 의하여 공무담임권을 가진다. 모든 국민은 인간다운 생활을 할 권리를 가진다. 지방의회의 조직·권한·의원선거와 지방자치단체의 장의 선임방법 기타 지방자치단체의 조직과 운영에 관한 사항은 법률로 정한다. 이 헌법은 1988년 2월 25일부터 시행한다. 다만, 이 헌법을 시행하기 위하여 필요한 법률의 제정·개정과 이 헌법에 의한 대통령 및 국회의원의 선거 기타 이 헌법시행에 관한 준비는 이 헌법시행 전에 할 수 있다."
  }
  
  private let replyButton = UIButton().then {
    $0.setTitle("답글달기", for: .normal)
    $0.setTitleColor(.mediumGray, for: .normal)
    $0.titleLabel?.font = .overLine
    $0.setContentHuggingPriority(.required, for: .horizontal)
  }
  
  private let footerSeparatorLabel = UILabel().then {
    $0.text = "|"
    $0.textColor = .mediumGray
    $0.font = .overLine
    $0.setContentHuggingPriority(.required, for: .horizontal)
  }
  
  private let datetimeLabel = UILabel().then {
    $0.text = "방금 전"
    $0.textColor = .mediumGray
    $0.font = .overLine
  }
  
  // MARK: - Initializations
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
    setupConstraints()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  private func setupLayouts() {
    contentView.addSubview(wholeStackView)
    
    [replyImageView, profileImageView, contentStackView].forEach {
      wholeStackView.addArrangedSubview($0)
    }
    
    [headerStackView, commentLabel, footerStackView].forEach {
      contentStackView.addArrangedSubview($0)
    }
    
    [authorStackView, settingButton].forEach {
      headerStackView.addArrangedSubview($0)
    }
    
    [repliedAuthorLabel, authorInformationStackView].forEach {
      authorStackView.addArrangedSubview($0)
    }
    
    [authorLabel, authorIndicationView].forEach {
      authorInformationStackView.addArrangedSubview($0)
    }
    authorIndicationView.addSubview(authorIndicationLabel)
    
    [replyButton, footerSeparatorLabel, datetimeLabel].forEach {
      footerStackView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    
    wholeStackView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
      $0.top.equalToSuperview().inset(8)
      $0.bottom.equalToSuperview().inset(4)
    }
    
    replyImageView.snp.makeConstraints {
      $0.size.equalTo(16)
    }
    
    profileImageView.snp.makeConstraints {
      $0.size.equalTo(24)
    }
    
    authorIndicationLabel.snp.makeConstraints {
      $0.directionalVerticalEdges.equalToSuperview().inset(2)
      $0.directionalHorizontalEdges.equalToSuperview().inset(6)
    }
  }
    
  private func bind() {
    replyButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedReplyButton(commentID: owner.commentID)
      }
      .disposed(by: disposeBag)
    
    settingButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedOptionButton(commentID: owner.commentID)
      }
      .disposed(by: disposeBag)
  }
  
  func configure(with model: CommentContent) {
    if let imageLink = model.profileImageURL, imageLink.isEmpty == false {
      profileImageView.kf.setImage(with: URL(string: imageLink)!)
    } else {
      profileImageView.image = UIImage(named: "userDefaultImage")
    }
    commentLabel.text = model.content
    authorLabel.text = model.nickname
    
    // reply process
    replyImageView.isHidden = model.type == .normal
    repliedAuthorLabel.isHidden = model.type == .normal
    repliedAuthorLabel.text = "\(model.parentCommentNickname ?? "") 님에게 쓴 답글"
    
    // author process
    authorIndicationView.isHidden = !model.isAuthorComment
    
    // Inject comment ID
    commentID = model.commentID
    
    // posting date process
    guard let date = DateFormatterFactory.dateTime.date(from: model.postDate) else {
      Log.error("날짜 dateFormat이 이상하게 내려오거나 DateFormatter 처리를 잘못함\n내려온 댓글 날짜: \(model.postDate)\n작업하려는 날짜 포맷: \(DateFormatterFactory.dateTime.dateFormat ?? "None")", category: .ui)
      return
    }
    
    datetimeLabel.text = "\(DateFormatterFactory.commentDate.string(from: date))"
  }
}
