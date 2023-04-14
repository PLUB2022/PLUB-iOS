//
//  PLUBToast.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/14.
//

import UIKit

import SnapKit
import Then

/// `Toast` 클래스입니다.
final class PLUBToast: UIView {
  
  // MARK: - Properties
  
  /// Toast에 들어갈 text
  private var text: String? {
    get { label.text }
    set { label.text = newValue }
  }
  
  /// Toast의 지속 시간
  private var duration: Duration
  
  // MARK: - UI Components
  
  private let label = UILabel().then {
    $0.font = .button
    $0.numberOfLines = 0
    $0.textColor = .white
  }
  
  // MARK: - Initializations
  
  /// private init입니다. Toast를 만들고 싶다면
  /// `makeToast`를 이용해주세요.
  private init(text: String?, duration: Duration) {
    self.duration = duration
    super.init(frame: .zero)
    self.text = text
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  private func setupLayouts() {
    addSubview(label)
  }
  
  /// 오토레이아웃을 세팅합니다.
  ///
  /// label의 width에 lessThanOrEqualToSuperview()를 사용함으로써
  /// 1줄일 때 중앙정렬, 2줄 이상일 때 좌측정렬이 됩니다.
  private func setupConstraints() {
    label.snp.makeConstraints {
      $0.width.lessThanOrEqualToSuperview().inset(Metrics.Padding.horizontal)
      $0.height.equalToSuperview().inset(Metrics.Padding.vertical)
      $0.center.equalToSuperview()
    }
  }
  
  private func setupStyles() {
    backgroundColor = .black
    layer.cornerRadius = 8
    clipsToBounds = true
    alpha = 0
  }
}

// MARK: - Constants

extension PLUBToast {
  
  /// Toast 지속 시간을 설정하는 enum입니다.
  enum Duration {
    case short
    case long
    
    var value: Double {
      switch self {
      case .short:            return 1.5
      case .long:             return 3
      }
    }
  }
  
  private enum Metrics {
    enum Padding {
      static let horizontal   = 24
      static let vertical     = 16
    }
  }
}
