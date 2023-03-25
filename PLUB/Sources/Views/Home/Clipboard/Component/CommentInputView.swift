//
//  CommentTextView.swift
//  PLUB
//
//  Created by 홍승현 on 2023/03/25.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class CommentInputView: UIView {
  
  // MARK: - Properties
  
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private let containerView = UIStackView().then {
    $0.alignment = .center
    $0.spacing = 8
  }
  
  private let textView = UITextView().then {
    $0.textColor = .black
    $0.font = .body1
    $0.textContainerInset = .init(top: 4, left: 8, bottom: 4, right: 0)
    $0.isScrollEnabled = false
  }
  
  private let uploadButton = UIButton().then {
    $0.setImage(UIImage(named: "arrowUpFilledCircle"), for: .normal)
    $0.isHidden = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    addSubview(containerView)
    [textView, uploadButton].forEach {
      containerView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    containerView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    textView.snp.makeConstraints {
      $0.height.greaterThanOrEqualTo(32)
      
    }
    
    uploadButton.snp.makeConstraints {
      $0.size.equalTo(32)
    }
  }
}

extension CommentInputView {
  enum Constants {
    static let placeholder = "댓글을 입력하세요"
  }
}
