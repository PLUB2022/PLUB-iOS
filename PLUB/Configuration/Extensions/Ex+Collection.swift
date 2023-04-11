//
//  Ex+Collection.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/10.
//

extension Collection {
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
