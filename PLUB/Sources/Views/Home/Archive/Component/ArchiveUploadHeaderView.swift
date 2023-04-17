//
//  ArchiveUploadHeaderView.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/17.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class ArchiveUploadHeaderView: UICollectionReusableView {
  
  // MARK: - Properties
  
  static let identifier = "\(ArchiveUploadHeaderView.self)"
  
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private let titleLabel = UILabel().then {
    $0.text = "제목"
    $0.textColor = .black
    $0.font = .subtitle
  }
  
  private let textField = PaddingTextField(left: 8, right: 8).then {
    $0.layer.cornerRadius = 8
    $0.backgroundColor = .white
    $0.textColor = .black
    $0.font = .body1
    $0.attributedPlaceholder = NSAttributedString(
      string: "제목을 입력해주세요",
      attributes: [.font: UIFont.body2]
    )
  }
  
  private let pictureLabel = UILabel().then {
    $0.text = "사진"
    $0.textColor = .black
    $0.font = .subtitle
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
  
  // MARK: - Configurations
  
  private func setupLayouts() {
    [titleLabel, textField, pictureLabel].forEach {
      addSubview($0)
    }
  }
  
  private func setupConstraints() {
    
    titleLabel.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.top.equalToSuperview().inset(24)
    }
    
    textField.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(8)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(46)
    }
    
    pictureLabel.snp.makeConstraints {
      $0.top.equalTo(textField.snp.bottom).offset(32)
      $0.bottom.directionalHorizontalEdges.equalToSuperview()
    }
  }
  
  private func setupStyles() {
    backgroundColor = .systemGray // for test
  }
}
