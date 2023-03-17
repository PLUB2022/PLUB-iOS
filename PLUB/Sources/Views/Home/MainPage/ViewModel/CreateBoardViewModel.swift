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
  var whichUpload: AnyObserver<BoardsRequest> { get }
  
  // Output
  var isSuccessCreateBoard: Signal<Int> { get }
}

final class CreateBoardViewModel: CreateBoardViewModelType {
  
  // Input
  let whichUpload: AnyObserver<BoardsRequest>
  
  // Output
  let isSuccessCreateBoard: Signal<Int>
  
  init() {
    let whichUploading = PublishSubject<BoardsRequest>()
    self.whichUpload = whichUploading.asObserver()
    
    let createBoard = whichUploading
      .flatMapLatest { request in
        return FeedsService.shared.createBoards(plubbingID: 0, model: request)
      }
    
    let successCreateBoard = createBoard.compactMap { result -> BoardsResponse? in
      print("결과 \(result)")
      guard case .success(let response) = result else { return nil }
      return response.data
    }
    
    // Output
    isSuccessCreateBoard = successCreateBoard
      .map { $0.feedID }
      .asSignal(onErrorSignalWith: .empty())
  }
}
