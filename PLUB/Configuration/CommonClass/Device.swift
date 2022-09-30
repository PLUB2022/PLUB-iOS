//
//  Device.swift
//  PLUB
//
//  Created by 양유진 on 2022/09/30.
//

import Foundation
import UIKit

// MARK: 디바이스의 크기, 여백 등의 정보를 담은 struct
// 참고하면 좋은 사이트 : https://kapeli.com/cheat_sheets/iOS_Design.docset/Contents/Resources/Documents/index
struct Device {
  
  // MARK: 디바이스 width
  static var width: CGFloat {
    return UIScreen.main.bounds.width
  }
  
  // MARK: 디바이스 height
  static var height: CGFloat {
    return UIScreen.main.bounds.height
  }
  
  // MARK: 노치 디자인인지 아닌지
  static var isNotch: Bool {
    let scenes = UIApplication.shared.connectedScenes
    let windowScene = scenes.first as? UIWindowScene
    let window = windowScene?.windows.first
    return Double(window?.safeAreaInsets.bottom ?? -1) > 0
  }
  
  // MARK: 상태바 높이
  static var statusBarHeight: CGFloat {
    let scenes = UIApplication.shared.connectedScenes
    let windowScene = scenes.first as? UIWindowScene

    return windowScene?.statusBarManager?.statusBarFrame.height ?? 0
  }
  
  // MARK: 네비게이션 바 높이
  static var navigationBarHeight: CGFloat {
    return UINavigationController().navigationBar.frame.height
  }
  
  // MARK: 탭 바 높이
  static var tabBarHeight: CGFloat {
    return UITabBarController().tabBar.frame.height
  }
  
  // MARK: 디바이스의 위쪽 여백 (Safe Area 위쪽 여백)
  // ** 위쪽 여백의 전체 높이 : topInset + statusBarHeight + navigationBarHeight(존재하는 경우) **
  static var topInset: CGFloat {
    let scenes = UIApplication.shared.connectedScenes
    let windowScene = scenes.first as? UIWindowScene
    let window = windowScene?.windows.first
    return window?.safeAreaInsets.top ?? 0
  }
  
  // MARK: 디바이스의 아래쪽 여백 (Safe Area 아래쪽 여백)
  // ** 아래쪽 여백의 전체 높이 : bottomInset + tabBarHeight(존재하는 경우) **
  static var bottomInset: CGFloat {
    let scenes = UIApplication.shared.connectedScenes
    let windowScene = scenes.first as? UIWindowScene
    let window = windowScene?.windows.first
    return window?.safeAreaInsets.bottom ?? 0
  }
}

