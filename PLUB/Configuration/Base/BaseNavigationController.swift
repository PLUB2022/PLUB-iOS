//
//  BaseNavigationController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/03/10.
//

import UIKit

class BaseNavigationController: UINavigationController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    interactivePopGestureRecognizer?.delegate = self
  }
}

// MARK: - UIGestureRecognizerDelegate

extension BaseNavigationController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    viewControllers.count > 1
  }
}
