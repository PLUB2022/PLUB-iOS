//
//  CreateBoardViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/18.
//

import RxSwift
import RxCocoa

protocol CreateBoardViewModelType {
  // Input
  var uploadBoard: AnyObserver<Void> { get }
  
  // Output
}

final class CreateBoardViewModel: CreateBoardViewModelType {
  
  // Input
  let uploadBoard: AnyObserver<Void>
  
  // Output
  
  init() {
    let uploadingBoard = PublishSubject<Void>()
    self.uploadBoard = uploadingBoard.asObserver()
  }
}
