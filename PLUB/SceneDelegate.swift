//
//  SceneDelegate.swift
//  PLUB
//
//  Created by 홍승현 on 2022/09/28.
//

import UIKit

import GoogleSignIn
import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = UINavigationController(rootViewController: SplashViewController())
    window?.rootViewController = UINavigationController(rootViewController: MainPageViewController())
    window?.makeKeyAndVisible()
  }
  
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    if let url = URLContexts.first?.url {
      if AuthApi.isKakaoTalkLoginUrl(url) {
        _ = AuthController.handleOpenUrl(url: url)
      }
    }
    
    if let url = URLContexts.first?.url {
      let handled = GIDSignIn.sharedInstance.handle(url)
      
      // Handle other custom URL types.
      // If not handled by this app, prints `false`.
      print(handled)
    }
  }
}
