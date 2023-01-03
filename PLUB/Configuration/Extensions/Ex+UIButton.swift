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
}
