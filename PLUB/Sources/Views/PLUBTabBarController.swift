//
//  PLUBTabBarController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/07.
//

import UIKit

import SnapKit
import Then

final class PLUBTabBarController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  private func setupLayouts() {
    viewControllers = [
      BaseNavigationController(
        rootViewController: HomeViewController(viewModel: HomeViewModel()).then {
          $0.tabBarItem = UITabBarItem(title: "메인", image: UIImage(named: "house24"), tag: 0)
        }
      ),
      BaseNavigationController(
        rootViewController: MeetingViewController().then {
          $0.tabBarItem = UITabBarItem(title: "내 모임", image: UIImage(named: "peopleCommunity24"), tag: 1)
        }
      ),
      BaseNavigationController(
        rootViewController: ClipboardViewController(viewModel: ClipboardViewModel(plubIdentifier: 59)).then {
          $0.tabBarItem = UITabBarItem(title: "알림", image: UIImage(named: "bell24"), tag: 2)
        }
      ),
      BaseNavigationController(
        rootViewController: UIViewController().then {
          $0.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(named: "personOutline24"), tag: 3)
        }
      )
    ]
  }
  
  private func setupConstraints() {
    
  }
  
  private func setupStyles() {
    tabBar.tintColor = .main
    tabBar.backgroundColor = .white
    
    // tab bar corner radius
    tabBar.layer.cornerRadius = 20
    tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    
    // tab bar appearance
    tabBar.standardAppearance = UITabBarAppearance().then {
      $0.stackedLayoutAppearance = UITabBarItemAppearance().then {
        // Deselected state
        $0.normal.titleTextAttributes = [.font: UIFont.appFont(family: .pretendard(option: .regular), size: 10)]
        
        // Selected State
        $0.selected.titleTextAttributes = [.font: UIFont.appFont(family: .pretendard(option: .bold), size: 10)]
      }
    }
  }
}
