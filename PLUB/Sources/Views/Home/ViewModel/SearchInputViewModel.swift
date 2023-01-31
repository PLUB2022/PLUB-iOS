//
//  SearchInputViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/28.
//

import RxSwift
import RxCocoa

protocol SearchInputViewModelType {
  // Input
  var whichKeyword: AnyObserver<String> { get }
  
  // Output
}

final class SearchInputViewModel: SearchInputViewModelType {
  private let disposeBag = DisposeBag()
  
  // Input
  let whichKeyword: AnyObserver<String>
  
  // Output
  
  init() {
    let searchKeyword = PublishSubject<String>()
    self.whichKeyword = searchKeyword.asObserver()
    
    
  }
}
