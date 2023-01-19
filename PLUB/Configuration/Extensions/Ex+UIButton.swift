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
