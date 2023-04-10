//
//  AppDelegate.swift
//  PLUB
//
//  Created by 홍승현 on 2022/09/28.
//

import UIKit

import GoogleSignIn
import KakaoSDKCommon
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    KakaoSDK.initSDK(appKey: KeyConstants.kakaoNativeAppKey)
    
    GIDSignIn.sharedInstance.configuration = GIDConfiguration(
      clientID: KeyConstants.googleID,
      serverClientID: KeyConstants.googleServerClientID
    )
    
    FirebaseApp.configure()
    configureCloudMessaging(application)
    
    setupNavigationBarStyle()
    
    return true
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
  }
  
  // MARK: Configuration Methods
  
  private func configureCloudMessaging(_ application: UIApplication) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
      
    }
    
    application.registerForRemoteNotifications()
    
    Messaging.messaging().delegate = self
  }
  
  private func setupNavigationBarStyle() {
    let appearance = UINavigationBarAppearance()
    
    appearance.configureWithOpaqueBackground() // 반투명 색상
    appearance.backgroundColor = .background // 배경색
    
    appearance.titleTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.black, // 텍스트 색상
      NSAttributedString.Key.font: UIFont.h4 // 폰트
    ]
    
    // 내비바 하단 회색선 제거
    appearance.shadowColor = .clear
    appearance.shadowImage = UIImage()
    
    UINavigationBar.appearance().tintColor = .black
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
  }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    Log.notice(fcmToken)
  }
}
