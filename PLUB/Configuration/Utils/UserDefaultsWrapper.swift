//
//  UserDefaultsWrapper.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/15.
//

import Foundation

@propertyWrapper
struct UserDefaultsWrapper<T> {
    
  private let key: String
  
  init(key: String) {
    self.key = key
  }
  
  var wrappedValue: T? {
    get {
      return UserDefaults.standard.object(forKey: self.key) as? T
    }
    set {
      if newValue == nil { UserDefaults.standard.removeObject(forKey: key) }
      else { UserDefaults.standard.setValue(newValue, forKey: key) }
    }
  }
}
