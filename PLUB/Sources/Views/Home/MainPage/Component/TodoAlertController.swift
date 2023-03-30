//
//  TodoAlertViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/30.
//

import UIKit

import SnapKit
import Then

final class TodoAlertController: BaseViewController {
  private let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
  }
  
  private let profileImageView = UIImageView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 8
  }
  
  private let dateLabel = UILabel().then {
    $0.font = .overLine
    $0.textColor = .black
  }
  
  private let nameLabel = UILabel().then {
    $0.font = .caption2
    $0.textColor = .black
  }
  
  private let closeButton = UIButton().then {
    $0.setImage(UIImage(named: ""), for: .normal)
  }
}
