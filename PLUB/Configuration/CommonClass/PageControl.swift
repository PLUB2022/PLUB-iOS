//
//  PageControl.swift
//  PLUB
//
//  Created by 홍승현 on 2022/12/24.
//

import UIKit

import SnapKit
import Then

final class PageControl: UIControl {
  
  // MARK: - Properties
  
  // MARK: Private Properties
  
  /// dots를 갖고있는 스택뷰
  private let stackView: UIStackView = UIStackView().then {
    $0.spacing = 8
    $0.distribution = .equalSpacing
    $0.alignment = .center
  }
  
  /// caching UIViews
  ///
  /// numberOfPages가 변동되면 자동으로 그 수 만큼의 UIView 배열이 초기화됩니다.
  private var dots: [UIView] = [] {
    willSet {
      configure(dots: newValue)
    }
    didSet {
      clear(dots: oldValue)
    }
  }
  
  private var _currentPage: Int = 0 {
    didSet {
      updateDotsConstraints()
      updateDotsStyles()
      startDotAnimations()
    }
  }
  
  // MARK: Public Properties
  
  /// 페이지 수, 해당 수 만큼 점으로 표시됩니다.
  ///
  /// 이 프로퍼티는 `PageControl`이 점으로 표시할 페이지 수입니다. 기본값은 0입니다.
  var numberOfPages: Int = 0 {
    didSet {
      createDots()
    }
  }
  
  /// 현재 페이지, 해당 `인덱스` 값에 따라 점(dot)이 길고 파란(Plub의 메인 색)으로 표시됩니다.
  ///
  /// 이 프로퍼티는 현재 표시된 페이지를 지정하는 정수로, 값 0(기본값)은 첫 번째 페이지를 의미합니다.
  /// 해당 클래스인 `PageControl`은 현재 페이지를  Plub의 main색으로 표시합니다.
  /// 가능한 범위 밖의 값은 0 또는 `numberOfPages-1` 중 하나로 고정됩니다.
  var currentPage: Int {
    get {
      return self._currentPage
    }
    set {
      if self._currentPage == newValue { return }
      
      if newValue >= numberOfPages {
        self._currentPage = numberOfPages - 1
      }
      else if newValue < 0 {
        self._currentPage = 0
      }
      else {
        self._currentPage = newValue
      }
    }
  }
  
  /// `page indicator`에 적용할 `tint color`
  ///
  /// 기본 색상은 `mediumGray`입니다.
  /// page indicator dot은 화면에 표시되지 않은 모든 페이지에 사용됩니다.
  var pageIndicatorTintColor: UIColor? = .mediumGray {
    didSet {
      updateDotsStyles()
    }
  }
  
  /// 현재 페이지에 적용할 `tint Color`
  ///
  /// 기본 색상은 `main`입니다.
  /// page indicator dot은 화면에 표시되는 페이지에 사용됩니다.
  var currentPageIndicatorTintColor: UIColor? = .main {
    didSet {
      updateDotsStyles()
    }
  }
  
  /// 현재 페이지에 적용할 `indicator의 가로 길이`
  ///
  /// 기본값은 `40`입니다.
  /// page indicator dot은 화면에 표시되는 페이지에 사용됩니다.
  var currentPageIndicatorWidth: Int = 40 {
    didSet {
      updateDotsConstraints()
    }
  }
  
  /// `page indicator`에 적용할 `indicator의 가로 길이`
  ///
  /// 기본값은 `10`입니다.
  /// page indicator dot은 화면에 표시되지 않은 모든 페이지에 사용됩니다.
  var pageIndicatorWidth: Int = 10 {
    didSet {
      updateDotsConstraints()
    }
  }
  
  // MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configuration
  
  private func configureUI() {
    self.addSubview(stackView)
    
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  // MARK: - Dot Methods
  
  private func createDots() {
    var dots = [UIView]()
    for _ in 0..<numberOfPages {
      let dot = UIView()
      dots.append(dot)
    }
    self.dots = dots
  }
  
  private func configure(dots: [UIView]) {
    for (index, dot) in dots.enumerated() {
      
      // == dot view hirerchys ==
      stackView.addArrangedSubview(dot)
      
      // == dot constraints ==
      dot.snp.makeConstraints {
        if index == _currentPage {
          $0.width.equalTo(currentPageIndicatorWidth)
        } else {
          $0.width.equalTo(pageIndicatorWidth)
        }
        $0.height.equalTo(8)
      }
      
      // == dot appearence ==
      dot.clipsToBounds = false
      dot.layer.cornerRadius = 4
      dot.backgroundColor = index == _currentPage ? currentPageIndicatorTintColor : pageIndicatorTintColor
    }
  }
  
  private func clear(dots: [UIView]) {
    dots.forEach {
      $0.snp.removeConstraints()  // Constraint 제거
      $0.removeFromSuperview()    // 부모뷰로부터 제거
    }
  }
  
  private func updateDotsConstraints() {
    for (index, dot) in dots.enumerated() {
      dot.snp.updateConstraints {
        if index == _currentPage {
          $0.width.equalTo(currentPageIndicatorWidth)
        } else {
          $0.width.equalTo(pageIndicatorWidth)
        }
      }
    }
  }
  
  private func updateDotsStyles() {
    for (index, dot) in dots.enumerated() {
      dot.backgroundColor = index == _currentPage ? currentPageIndicatorTintColor : pageIndicatorTintColor
    }
  }
  
  // MARK: - Animations
  
  private func startDotAnimations() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.68, initialSpringVelocity: 3, options: .curveEaseOut) {
      self.layoutIfNeeded()
    }
  }
}
