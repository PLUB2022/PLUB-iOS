//
//  BottomSheetViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/17.
//

import UIKit

import SnapKit

class BottomSheetViewController: BaseViewController {
  
  /// BottomSheet를 사용할 때 View 객체를 contentView에 넣어야합니다.
  let contentView = UIView()
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(contentView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    contentView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    contentView.layoutIfNeeded()
    let height = contentView.frame.height
    guard let sheet = sheetPresentationController else { return }
    sheet.detents = [.custom(identifier: .bottomSheet) { context in
      return height
    }]
    
    sheet.prefersScrollingExpandsWhenScrolledToEdge        = false
    sheet.prefersEdgeAttachedInCompactHeight               = true
    sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
    sheet.prefersGrabberVisible                            = true
  }
}

extension UISheetPresentationController.Detent.Identifier {
  static let bottomSheet = Self("bottomSheet")
}

// MARK: - Constants

extension BottomSheetViewController {
  enum Metrics {
    enum Margin {
      static let horizontal = 16
      static let top        = 36
      static let bottom     = 24
    }
    
    enum Size {
      static let height     = 48
    }
  }
}
