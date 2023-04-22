//
//  ExportTableViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/23.
//

import UIKit

import SnapKit
import Then
import RxSwift

protocol ExportTableViewCellDelegate: AnyObject {
  func didTappedExportButton(indexPathRow: Int)
}

final class ExportTableViewCell: UITableViewCell {
  static let identifier = "ExportTableViewCell"
  private var indexPathRow: Int?
  private let disposeBag = DisposeBag()
  weak var delegate: ExportTableViewCellDelegate?
  
  private let contentStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.spacing = 16
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
    $0.layer.cornerRadius = 10
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.borderWidth = 1
    $0.backgroundColor = .white
  }
  
  private let profileImageView = UIImageView().then {
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 20
  }
  
  private let nicknameLabel = UILabel().then {
    $0.font = .subtitle
    $0.textColor = .black
  }
  
  private let exportButton = UIButton().then {
    $0.setTitle("강퇴", for: .normal)
    $0.setTitleColor(.deepGray, for: .normal)
    $0.titleLabel?.font = .button
    $0.layer.cornerRadius = 8
    $0.backgroundColor = .lightGray
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayouts()
    setupConstraints()
    setupStyles()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    contentView.addSubview(contentStackView)
    [profileImageView, nicknameLabel, exportButton].forEach {
      contentStackView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    contentStackView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
      $0.directionalVerticalEdges.equalToSuperview().inset(6)
    }
    
    profileImageView.snp.makeConstraints {
      $0.size.equalTo(40)
    }
    
    exportButton.snp.makeConstraints {
      $0.width.equalTo(56)
      $0.height.equalTo(29)
    }
  }
  
  private func setupStyles() {
    selectionStyle = .none
    backgroundColor = .background
  }
  
  private func bind() {
    exportButton.rx.tap
      .subscribe(with: self) { owner, _ in
        guard let indexPathRow = owner.indexPathRow else { return }
        owner.delegate?.didTappedExportButton(indexPathRow: indexPathRow)
      }
      .disposed(by: disposeBag)
  }
  
  func setupData(with data: AccountInfo, indexPathRow: Int) {
    self.indexPathRow = indexPathRow
    nicknameLabel.text = data.nickname
    
    if let profileImage = data.profileImage,
       let profileImageURL = URL(string: profileImage) {
      profileImageView.kf.setImage(with: profileImageURL)
    } else {
      profileImageView.image = UIImage(named: "userDefaultImage")
    }
  }
}
