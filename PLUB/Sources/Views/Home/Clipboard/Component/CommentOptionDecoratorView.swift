//
//  CommentOptionDecoratorView.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/14.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

protocol CommentOptionViewDelegate: AnyObject {
  func cancelButtonTapped()
}

final class CommentOptionDecoratorView: UIView {
  
  // MARK: - Properties
  
  /// 왼쪽에 들어갈 label text를 설정합니다.
  var labelText: String = "Unknown" {
    didSet {
      indicatorLabel.text = labelText
    }
  }
  
  /// 오른쪽 버튼에 들어갈 text를 설정합니다.
  var buttonText: String = "취소" {
    didSet {
      cancelButton.setTitle(buttonText, for: .normal)
    }
  }
  
  weak var delegate: CommentOptionViewDelegate?
  
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private let separatorLineView = UIView().then {
    $0.backgroundColor = .lightGray
  }
  
  private let indicatorLabel = UILabel().then {
    $0.font = .overLine
    $0.textColor = .black
  }
  
  private let cancelButton = UIButton().then {
    $0.setTitleColor(.main, for: .normal)
    $0.setTitle("답글 작성 취소", for: .normal)
    $0.titleLabel?.font = .overLine
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
  
  // MARK: - Configuration
  
  private func setupLayouts() {
    [indicatorLabel, cancelButton, separatorLineView].forEach {
      addSubview($0)
    }
  }
  
  private func setupConstraints() {
    indicatorLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(Metrics.directionalHorizontalInset)
      $0.centerY.equalToSuperview()
    }
    
    cancelButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().inset(Metrics.directionalHorizontalInset)
    }
    
    separatorLineView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(Metrics.separatorHeight)
    }
  }
  
  private func bind() {
    cancelButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.cancelButtonTapped()
      }
      .disposed(by: disposeBag)
  }
}

extension CommentOptionDecoratorView {
  enum Metrics {
    static let directionalHorizontalInset = 24
    static let separatorHeight = 1
  }
}
