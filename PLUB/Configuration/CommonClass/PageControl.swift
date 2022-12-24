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
  
  // MARK: - Property
  
  private var dots: [UIView] = []
  
  
  /// 페이지 수, 해당 수 만큼 점으로 표시됩니다.
  ///
  /// 이 프로퍼티는 `PageControl`이 점으로 표시할 페이지 수입니다. 기본값은 0입니다.
  var numberOfPages: Int = 0
  
  /// 현재 페이지, 해당 `인덱스` 값에 따라 점(dot)이 길고 파란(Plub의 메인 색)으로 표시됩니다.
  ///
  /// 이 프로퍼티는 현재 표시된 페이지를 지정하는 정수로, 값 0(기본값)은 첫 번째 페이지를 의미합니다.
  /// 해당 클래스인 `PageControl`은 현재 페이지를  Plub의 main색으로 표시합니다.
  /// 가능한 범위 밖의 값은 0 또는 `numberOfPages-1` 중 하나로 고정됩니다.
  var currentPage: Int = 0
  
  /// `page indicator`에 적용할 `tint color`
  ///
  /// 기본 색상은 `mediumGray`입니다.
  /// page indicator dot은 화면에 표시되지 않은 모든 페이지에 사용됩니다.
  var pageIndicatorTintColor: UIColor? = .mediumGray
  
  /// 현재 페이지에 적용할 `tint Color`
  ///
  /// 기본 색상은 `main`입니다.
  /// page indicator dot은 화면에 표시되는 페이지에 사용됩니다.
  var currentPageIndicatorTintColor: UIColor? = .main
  
  
  // MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
