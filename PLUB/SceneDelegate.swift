//
//  SceneDelegate.swift
//  PLUB
//
//  Created by νμΉν on 2022/09/28.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = UINavigationController(rootViewController: ApplyQuestionViewController(viewModel: ApplyQuestionViewModel()))
    window?.rootViewController = UINavigationController(rootViewController: HomeViewController())
    window?.makeKeyAndVisible()
  }
}
