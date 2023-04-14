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
  
  /// Toast를 생성합니다.
  /// 생성될 때, 적절한 위치에 맞추어 Toast가 나타났다가 사라지게 됩니다.
  /// - Parameters:
  ///   - text: Toast 내부에 들어갈 텍스트
  ///   - duration: Toast의 지속시간, `.short`는 1.5초, `.long`은 3초입니다.
  static func makeToast(text: String?, duration: Duration = .long) {
    guard let text, text.isEmpty == false else { return }
    
    let toast = PLUBToast(text: text, duration: duration)
    
    guard let window = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .flatMap(\.windows)
      .first(where: \.isKeyWindow)
    else {
      return
    }
    
    window.addSubview(toast)
    toast.snp.makeConstraints {
      $0.bottom.equalTo(window.safeAreaLayoutGuide).inset(Metrics.Margin.vertical)
      $0.directionalHorizontalEdges.equalTo(window.safeAreaLayoutGuide).inset(Metrics.Margin.horizontal)
    }
    
    toast.showToast()
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
  
  // MARK: - Custom Methods
  
  /// Toast의 alpha값을 0에서 1로 변경하여 Toast가 보이도록 합니다.
  private func showToast() {
    UIView.animate(
      withDuration: 0.25,
      delay: 0,
      options: .curveEaseIn) {
        self.alpha = 1
      } completion: { _ in
        self.hideToast()
      }
  }
  
  /// 지속시간이 지난 이후 다시 alpha값을 0으로 만들어 Toast가 사라지도록 만듭니다.
  private func hideToast() {
    UIView.animate(
      withDuration: 0.25,
      delay: duration.value,
      options: .curveEaseOut) {
        self.alpha = 0
      } completion: { _ in
        self.removeToast()
      }
  }
  
  /// Toast를 제거합니다.
  private func removeToast() {
    self.removeFromSuperview()
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
    enum Margin {
      static let horizontal   = 24
      static let vertical     = 60
    }
    
    enum Padding {
      static let horizontal   = 24
      static let vertical     = 16
    }
  }
}
