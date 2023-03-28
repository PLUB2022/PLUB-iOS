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

protocol CommentInputViewDelegate: AnyObject {
  /// 사용자가 작성한 댓글을 게시하려고 할 때 실행됩니다.
  /// - Parameters:
  ///   - textView: 입력된 텍스트가 포함된 UITextView입니다.
  ///   - writtenText: 작성된 댓글 텍스트입니다.
  func commentInputView(_ textView: UITextView, writtenText: String)
}

final class CommentInputView: UIView {
  
  // MARK: - Properties
  
  private let disposeBag = DisposeBag()
  
  weak var delegate: CommentInputViewDelegate?
  
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
    bind()
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
  
  private func bind() {
    uploadButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.delegate?.commentInputView(owner.textView, writtenText: owner.textView.text)
      }
      .disposed(by: disposeBag)
    
    textView.rx.text
      .orEmpty
      .distinctUntilChanged()
      .observe(on: MainScheduler.instance)
      .subscribe(with: self) { owner, text in
        // == 텍스트가 존재한다면 업로드 버튼 보이기 ==
        owner.uploadButton.isHidden = text.isEmpty
        
        // == text view dynamic height ==
        let size = CGSize(width: owner.textView.frame.width, height: .infinity)
        let estimatedSize = owner.textView.sizeThatFits(size)
        owner.textView.snp.remakeConstraints {
          $0.height.greaterThanOrEqualTo(32).priority(.required)
          $0.height.equalTo(estimatedSize.height).priority(.high)
        }
      }
      .disposed(by: disposeBag)
  }
}

extension CommentInputView {
  enum Constants {
    static let placeholder = "댓글을 입력하세요"
  }
}