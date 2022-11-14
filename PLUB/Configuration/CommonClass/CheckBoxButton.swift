//
//  CheckBoxButton.swift
//  PLUB
//
//  Created by 홍승현 on 2022/11/14.
//

import UIKit

import RxSwift
import RxCocoa

final class CheckBoxButton: UIButton {
  
  
}

extension CheckBoxButton {
  enum ButtonType {
    
    /// 체크되어있지 않을 때 비어있는 칸으로 보입니다.
    case none
    
    /// 체크되어있지 않을 때 회색의 체크표시 모양이 보입니다.
    case full
  }
}
