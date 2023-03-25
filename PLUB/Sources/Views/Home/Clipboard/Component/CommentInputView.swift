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
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension CommentInputView {
  enum Constants {
    static let placeholder = "댓글을 입력하세요"
  }
}
