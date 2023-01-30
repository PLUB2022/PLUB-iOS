//
//  HomeAlert.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/06.
//

import UIKit

import SnapKit
import Then

class HomeAlert {
  struct Constants {
    static let backgroundAlphaTo = 0.6
  }
  
  public static let shared = HomeAlert()
  
  private let backgroundView = UIView().then {
    $0.backgroundColor = .black
    $0.alpha = 0
  }
  
  private let alertView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 12
    $0.isUserInteractionEnabled = true
  }
  
  private lazy var stackView = UIStackView(arrangedSubviews: [applyImageView, mainLabel, subLabel, descriptionLabel]).then {
    $0.axis = .vertical
    $0.distribution = .fill
    $0.alignment = .center
  }
  
  private let applyImageView = UIImageView().then {
    $0.image = UIImage(named: "apply")
    $0.contentMode = .scaleAspectFit
  }
  
  private lazy var backButton = UIButton().then {
    $0.setImage(UIImage(named: "closeButton"), for: .normal)
  }
  
  private let mainLabel = UILabel().then {
    $0.textColor = .main
    $0.font = .h4
    $0.text = "지원완료 !"
    $0.numberOfLines = 0
    $0.sizeToFit()
  }
  
  private let subLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .body2
    $0.numberOfLines = 0
    $0.sizeToFit()
    $0.text = """
    정성스럽게 작성하신 답변을
    모임 호스트에게 전달했어요.
    """
  }
  
  private let descriptionLabel = UILabel().then {
    $0.text = """
    호스트가 수락하면 함께 활동할 수 있습니다.
    알림으로 알려드릴게요!
    """
    $0.textColor = .deepGray
    $0.numberOfLines = 0
    $0.font = .caption
  }
  
  private init() {
    backButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
  }
  
  public func showAlert(on viewController: UIViewController) {
    guard let targetView = viewController.view else { return }
    
    [backgroundView, alertView].forEach { targetView.addSubview($0) }
    [backButton, stackView].forEach { alertView.addSubview($0) }
    
    backgroundView.alpha = Constants.backgroundAlphaTo
    backgroundView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    alertView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.equalTo(296)
      $0.height.equalTo(448)
    }
    
    backButton.snp.makeConstraints {
      $0.width.height.equalTo(32)
      $0.top.right.equalToSuperview().inset(10)
    }
    
    stackView.snp.makeConstraints {
      $0.top.equalTo(backButton.snp.bottom)
      $0.left.right.bottom.equalToSuperview().inset(20)
    }
    
    applyImageView.snp.makeConstraints {
      $0.width.height.equalTo(224)
    }

    subLabel.snp.makeConstraints {
      $0.top.equalTo(mainLabel.snp.bottom)
      $0.height.equalTo(36)
    }
  }
  
  @objc private func dismissAlert() {
    UIView.animate(withDuration: 0.25) {
      self.backgroundView.alpha = 0
    } completion: { done in
      if done {
        self.alertView.removeFromSuperview()
        self.backgroundView.removeFromSuperview()
      }
    }
    
  }
}
