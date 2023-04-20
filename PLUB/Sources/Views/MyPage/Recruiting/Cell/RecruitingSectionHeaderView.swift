//
//  RecruitingSectionHeaderView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/17.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

struct RecruitingModel {
  let title: String
  let schedule: String
  let address: String
}

protocol RecruitingSectionHeaderViewDelegate: AnyObject {
  func foldHeaderView(sectionIndex: Int)
}

final class RecruitingSectionHeaderView: UITableViewHeaderFooterView {
  static let identifier = "RecruitingSectionHeaderView"
  weak var delegate: RecruitingSectionHeaderViewDelegate?
  private let disposeBag = DisposeBag()
  private var sectionIndex: Int? = nil
  
  private let containerView = UIView().then {
    $0.backgroundColor = .white
  }
  
  private let profileImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 20
  }
  
  private let textStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 4
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .subtitle
    $0.textColor = .black
  }
  
  private let subTitleLabel = UILabel().then {
    $0.font = .overLine
    $0.textColor = .init(hex: 0x838080)
  }
  
  private let foldImageView = UIImageView().then {
    $0.image = UIImage(named: "unfoldedArrow")
    $0.highlightedImage = UIImage(named: "foldedArrow")
  }
  
  private let button = UIButton()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setupLayouts()
    setupConstraints()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    containerView.roundCorners(corners: [.topLeft, .topRight], radius: 15)
    containerView.layer.addBorder([.top], color: .lightGray, width: 1)
  }
  
  private func setupLayouts() {
    [containerView, button].forEach {
      addSubview($0)
    }
    
    [profileImageView, textStackView, foldImageView].forEach {
      containerView.addSubview($0)
    }
    
    [titleLabel, subTitleLabel].forEach {
      textStackView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    containerView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(8)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.bottom.equalToSuperview()
    }
    
    profileImageView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(16)
      $0.leading.equalToSuperview().inset(20)
      $0.size.equalTo(40)
    }
    
    textStackView.snp.makeConstraints {
      $0.centerY.equalTo(profileImageView.snp.centerY)
      $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(19)
    }
    
    subTitleLabel.snp.makeConstraints {
      $0.height.equalTo(12)
    }
    
    foldImageView.snp.makeConstraints {
      $0.centerY.equalTo(profileImageView.snp.centerY)
      $0.trailing.equalToSuperview().inset(16)
      $0.size.equalTo(24)
    }
    
    button.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func bind() {
    button.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        guard let sectionIndex = owner.sectionIndex else { return }
        owner.delegate?.foldHeaderView(sectionIndex: sectionIndex)
      }
      .disposed(by: disposeBag)
  }
  
  func setupData(
    with model: (data: Application, isFolded: Bool),
    sectionIndex: Int
  ) {
    titleLabel.text = model.data.userName
    subTitleLabel.text = model.data.date
    if let imageURL = model.data.profileImage, let url = URL(string: imageURL) {
      profileImageView.kf.setImage(with: url)
    } else {
      profileImageView.image = UIImage(named: "userDefaultImage")
    }
    foldImageView.isHighlighted = !model.isFolded

    self.sectionIndex = sectionIndex
  }
}
