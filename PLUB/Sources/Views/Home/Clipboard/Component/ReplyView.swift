//
//  ReplyView.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/14.
//

import UIKit

final class ReplyView: UIView {
  
  // MARK: - Properties
  
  /// 답글을 달 닉네임을 설정합니다.
  var nickname: String = "Unknown" {
    didSet {
      replyIndicatorLabel.text = "\(nickname)님에게 답글 쓰는 중..."
    }
  }
  
  // MARK: - UI Components
  
  private let separatorLineView = UIView().then {
    $0.backgroundColor = .lightGray
  }
  
  private let replyIndicatorLabel = UILabel().then {
    $0.text = "~~님에게 답글 쓰는 중..."
    $0.font = .overLine
    $0.textColor = .black
  }
  
  private let replyCancelButton = UIButton().then {
    $0.setTitleColor(.main, for: .normal)
    $0.setTitle("답글 작성 취소", for: .normal)
    $0.titleLabel?.font = .overLine
  }
  
  // MARK: - Initializations
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configuration
  
  private func setupLayouts() {
    [replyIndicatorLabel, replyCancelButton, separatorLineView].forEach {
      addSubview($0)
    }
  }
  
  private func setupConstraints() {
    replyIndicatorLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(Metrics.directionalHorizontalInset)
      $0.centerY.equalToSuperview()
    }
    
    replyCancelButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().inset(Metrics.directionalHorizontalInset)
    }
    
    separatorLineView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(Metrics.separatorHeight)
    }
  }
}

extension ReplyView {
  enum Metrics {
    static let directionalHorizontalInset = 24
    static let separatorHeight = 1
  }
}
