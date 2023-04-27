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
  
  /// 댓글 작성란에 들어갈 텍스트를 입력합니다.
  var commentText: String {
    get {
      textView.text
    } set {
      textView.text = newValue
    }
  }
  
  private let disposeBag = DisposeBag()
  
  weak var delegate: CommentInputViewDelegate?
  
  // MARK: - UI Components
  
  private let commentSeparatorLineView = UIView().then {
    $0.backgroundColor = .lightGray
  }
  
  private let commentStackView = UIStackView().then {
    $0.spacing = 8
    $0.alignment = .top
  }
  
  private let profileImageView = UIImageView(image: .init(named: "userDefaultImage")).then {
    $0.contentMode = .scaleAspectFit
    $0.clipsToBounds = true
    $0.layer.cornerRadius = CGFloat(Size.initialStateHeight) * 0.5
  }
  
  private let textViewContainerView = UIStackView().then {
    $0.alignment = .center
    $0.spacing = 8
    $0.backgroundColor = .white
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 8
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
    [commentStackView, commentSeparatorLineView].forEach {
      addSubview($0)
    }
    
    [profileImageView, textViewContainerView].forEach {
      commentStackView.addArrangedSubview($0)
    }
    
    [textView, uploadButton].forEach {
      textViewContainerView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    
    commentStackView.snp.makeConstraints {
      $0.directionalVerticalEdges.equalToSuperview().inset(Margin.vertical)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Margin.horizontal)
    }
    
    profileImageView.snp.makeConstraints {
      $0.size.equalTo(Size.initialStateHeight)
    }
    
    textView.snp.makeConstraints {
      $0.height.greaterThanOrEqualTo(Size.initialStateHeight)
    }
    
    uploadButton.snp.makeConstraints {
      $0.size.equalTo(Size.initialStateHeight)
    }
    
    commentSeparatorLineView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(Size.barHeight)
    }
  }
  
  private func bind() {
    // 프로필 이미지 설정
    AccountService.shared.inquireMyInfo()
      .compactMap { result -> String? in
        guard case let .success(response) = result else { return nil }
        return response.data?.profileImage
      }
      .subscribe(with: self) { owner, profileImage in
        owner.profileImageView.kf.setImage(with: URL(string: profileImage))
      }
      .disposed(by: disposeBag)
    
    // 댓글 작성 버튼 탭
    uploadButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.delegate?.commentInputView(owner.textView, writtenText: owner.textView.text)
      }
      .disposed(by: disposeBag)
    
    textView.delegate = self
    
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
          $0.height.greaterThanOrEqualTo(Size.initialStateHeight).priority(.required)
          $0.height.equalTo(estimatedSize.height).priority(.high)
        }
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - UITextViewDelegate

extension CommentInputView: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let currentText = textView.text ?? ""
    guard let stringRange = Range(range, in: currentText) else { return false }

    let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

    return updatedText.count <= 300 // 300자 이내로만 작성 가능함
  }
}

// MARK: - Constants

private extension CommentInputView {
  enum Constants {
    static let placeholder = "댓글을 입력하세요"
  }
  
  enum Size {
    static let initialStateHeight = 32
    static let barHeight          = 1
  }
  
  enum Margin {
    static let vertical   = 8
    static let horizontal = 16
  }
}
