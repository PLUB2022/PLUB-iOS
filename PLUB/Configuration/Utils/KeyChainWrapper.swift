//
//  KeyChainWrapper.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/12.
//

import Foundation
import Security

@propertyWrapper
struct KeyChainWrapper<T: Codable> {
  
  private let key: String
  private let service: String = Bundle.main.bundleIdentifier!
  
  init(key: String) {
    self.key = key
  }
  
  var wrappedValue: T? {
    get {
      
    }
    set {
      
    }
  }
}
