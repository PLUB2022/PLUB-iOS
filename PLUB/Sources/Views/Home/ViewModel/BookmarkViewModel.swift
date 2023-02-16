//
//  BookmarkViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/16.
//

import RxSwift
import RxCocoa

protocol BookmarkViewModelType {
  // Input
  var tappedBookmark: AnyObserver<String> { get }
}

final class BookmarkViewModel: BookmarkViewModelType {
  // Input
  let tappedBookmark: AnyObserver<String> // 북마크버튼을 탭 했을때
  
  init() {
    let whichBookmark = PublishSubject<String>()
    
    tappedBookmark = whichBookmark.asObserver()
  }
}
