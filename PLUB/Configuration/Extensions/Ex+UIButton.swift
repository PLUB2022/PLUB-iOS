//
//  UIButton.swift
//  PLUB
//
//  Created by 양유진 on 2022/09/30.
//

import UIKit

import Then

// MARK: - Conform Then

extension UIButton.Configuration: Then { }
extension UIBackgroundConfiguration: Then { }
extension AttributedString: Then { }
extension AttributeContainer: Then { }

// MARK: - UIButton.Configuration

extension UIButton.Configuration {
  
  var font: UIFont? {
    get {
      self.attributedTitle?.font
    }
    set {
      self.attributedTitle?.font = newValue
    }
  }
  
  // MARK: Configuration Return Type
  
  /// 메인 색으로 fill되어있는 PLUB 버튼
  /// - Parameters:
  ///   - title: 버튼 내부의 text
  ///   - contentInsets: 버튼 내부 text와 버튼 테두리 사이의 inset
  static func plubFilledButton(title: String, contentInsets: NSDirectionalEdgeInsets) -> UIButton.Configuration {
    var style = UIButton.Configuration.filled()
    
    style.background = style.background.with {
      $0.cornerRadius = 6
      $0.backgroundColor = .subMain
    }
    
    style.contentInsets = contentInsets
    style.baseForegroundColor = .main
    style.title = title
    style.font = .button
    return style
  }
  
  /// 검색 조건 필터링 또는 알림 필터링에 들어갈 버튼입니다.
  ///
  /// PLUB Main 색으로 테두리와 title 오른쪽에 아래 화살표 이미지로 구성되어있습니다.
  /// - Parameter title: 버튼 내부에 들어갈 title
  static func plubFilterButton(title: String) -> UIButton.Configuration {
    var style = UIButton.Configuration.plain()
    
    style.background = style.background.with {
      $0.strokeColor = .main
      $0.strokeWidth = 1
      $0.strokeOutset = -1 // inside 1px
    }
    style.cornerStyle = .capsule
    
    style.image = .init(named: "filledTriangleDown")
    style.imagePlacement = .trailing
    
    style.contentInsets = .init(top: 2, leading: 12, bottom: 2, trailing: 4)
    style.baseForegroundColor = .main
    style.title = title
    style.font = .caption
    return style
  }
  
  private static func listDeselected() -> UIButton.Configuration {
    var style = UIButton.Configuration.plain()
    
    style.background = style.background.with {
      $0.cornerRadius = 8
      $0.strokeWidth = 1
      $0.strokeColor = .mediumGray
      $0.backgroundColor = .clear
    }
    style.baseForegroundColor = .deepGray
    
    return style
  }
  
  private static func listSelected() -> UIButton.Configuration {
    var style = UIButton.Configuration.plain()
    
    style.background = style.background.with {
      $0.cornerRadius = 8
      $0.backgroundColor = .main
    }
    style.baseForegroundColor = .white
    
    return style
  }
  
  private static func detailDeselected() -> UIButton.Configuration {
    var style = UIButton.Configuration.plain()
    
    style.background = style.background.with {
      $0.cornerRadius = 10
      $0.strokeWidth = 1
      $0.strokeColor = .lightGray
      $0.backgroundColor = .lightGray
    }
    style.baseForegroundColor = .deepGray
    
    return style
  }
  
  private static func detailSelected() -> UIButton.Configuration {
    var style = UIButton.Configuration.plain()
    
    style.background = style.background.with {
      $0.cornerRadius = 10
      $0.backgroundColor = .main
    }
    style.baseForegroundColor = .white
    
    return style
  }
  
  private static func plubButtonEnabled() -> UIButton.Configuration {
    var style = UIButton.Configuration.plain()
    
    style.background = style.background.with {
      $0.cornerRadius = 10
      $0.backgroundColor = .main
    }
    style.baseForegroundColor = .white
    
    return style
  }
  
  private static func plubButtonDisabled() -> UIButton.Configuration {
    var style = UIButton.Configuration.plain()
    
    style.background = style.background.with {
      $0.cornerRadius = 10
      $0.backgroundColor = .lightGray
    }
    style.baseForegroundColor = .deepGray
    
    return style
  }
  
  // MARK: - ConfigurationUpdateHandler
  
  func list(label text: String) -> UIButton.ConfigurationUpdateHandler {
    return { button in
      switch button.state {
      case .normal:
        button.configuration = .listDeselected()
      case .selected:
        button.configuration = .listSelected()
        break
      default: break
      }
      button.configuration?.title = text
      button.configuration?.font = .body1
    }
  }
  
  func detailRecruitment(label text: String) -> UIButton.ConfigurationUpdateHandler {
    return { button in
      switch button.state {
      case .normal:
        button.configuration = .detailDeselected()
      case .selected:
        button.configuration = .detailSelected()
        break
      default: break
      }
      button.configuration?.title = text
      button.configuration?.font = .body1
    }
  }
  
  func plubButton(label text: String) -> UIButton.ConfigurationUpdateHandler {
    return { button in
      switch button.state {
      case .normal:
        button.configuration = .plubButtonEnabled()
      case .disabled:
        button.configuration = .plubButtonDisabled()
      default: break
      }
      button.configuration?.title = text
      button.configuration?.font = .button
    }
  }
}
