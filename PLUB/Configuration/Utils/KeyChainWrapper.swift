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

// MARK: - Helper Properties & Functions

extension KeyChainWrapper {
  
  private var defaultQuery: [CFString: Any] {
    var query = [CFString: Any]()
    query[kSecClass] = kSecClassGenericPassword
    query[kSecAttrService] = service
    query[kSecAttrAccount] = key
    return query
  }
  
  private func get() -> Data? {
    var query = defaultQuery
    query[kSecReturnData] = true
    query[kSecMatchLimit] = kSecMatchLimitOne
    
    var dataTypeRef: CFTypeRef?
    guard SecItemCopyMatching(query as CFDictionary, &dataTypeRef) == errSecSuccess else {
      return nil
    }
    return dataTypeRef as? Data
  }
  
  private func set(value: Data) {
    removeValue()
    var query = defaultQuery
    query[kSecValueData] = value
    SecItemAdd(query as CFDictionary, nil)
  }
  
  private func removeValue() {
    let query = defaultQuery
    SecItemDelete(query as CFDictionary)
  }
}
