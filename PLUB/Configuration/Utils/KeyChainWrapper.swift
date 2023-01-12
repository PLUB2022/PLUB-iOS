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
  
  var wrappedValue: T? {
    get {
      
    }
    set {
      
    }
  }
}
