//
//  SplashViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/01.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class SplashViewController: BaseViewController {
  
  private let viewModel = SplashViewModel()
  
  /// PLUB Image
  private let imageView = UIImageView().then {
    $0.image = UIImage(named: "Logo")
    $0.contentMode = .scaleAspectFit
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(imageView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    imageView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview().inset(94)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
    
    let driver = viewModel.shouldMoveToVC
      .delay(.milliseconds(700)) // 어느정도 Splash화면이 보여지도록 0.7초 딜레이
    
    driver
      .filter { $0 is HomeViewController }
      .drive(with: self) { owner, vc in
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = PLUBTabBarController()
      }
      .disposed(by: disposeBag)
    
    driver
      .filter { !($0 is HomeViewController) }
      .drive(with: self) { owner, vc in
        owner.navigationController?.setViewControllers([vc], animated: true)
      }
      .disposed(by: disposeBag)
  }
}
