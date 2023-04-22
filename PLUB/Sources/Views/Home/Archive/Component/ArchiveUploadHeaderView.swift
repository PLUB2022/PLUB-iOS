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

protocol ArchiveUploadHeaderViewDelegate: AnyObject {
  /// 아카이브의 제목이 입력될 때마다 호출됩니다.
  /// - Parameter text: 입력받은 제목 문자열
  func archiveTitle(text: String)
}

final class ArchiveUploadHeaderView: UICollectionReusableView {
  
  // MARK: - Properties
  
  static let identifier = "\(ArchiveUploadHeaderView.self)"
  
  weak var delegate: ArchiveUploadHeaderViewDelegate?
  
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
    bind()
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
  
  private func bind() {
    textField.delegate = self
    
    // textField의 텍스트 값을 전달
    textField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .subscribe(with: self) { owner, text in
        owner.delegate?.archiveTitle(text: text)
      }
      .disposed(by: disposeBag)
  }
  
  func configure(with text: String) {
    textField.text = text
  }
}

// MARK: - UITextFieldDelegate

extension ArchiveUploadHeaderView: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let currentText = textField.text ?? ""
    guard let stringRange = Range(range, in: currentText) else { return false }

    let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

    return updatedText.count <= 16 // 16자 이내로만 작성 가능함
  }
}
