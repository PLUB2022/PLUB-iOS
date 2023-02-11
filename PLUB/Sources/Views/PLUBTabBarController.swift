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
      UINavigationController(
        rootViewController: HomeViewController(viewModel: HomeViewModel()).then {
          $0.tabBarItem = UITabBarItem(title: "메인", image: UIImage(named: "house24"), tag: 0)
        }
      ),
      UINavigationController(
        rootViewController: MeetingViewController().then {
          $0.tabBarItem = UITabBarItem(title: "내 모임", image: UIImage(named: "peopleCommunity24"), tag: 1)
        }
      ),
      UINavigationController(
        rootViewController: UIViewController().then {
          $0.tabBarItem = UITabBarItem(title: "알림", image: UIImage(named: "bell24"), tag: 2)
        }
      ),
      UINavigationController(
        rootViewController: UIViewController().then {
          $0.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(named: "personOutline24"), tag: 3)
        }
      )
    ]
  }
  
  private func setupConstraints() {
    
  }
  
  private func setupStyles() {
    
  }
}
