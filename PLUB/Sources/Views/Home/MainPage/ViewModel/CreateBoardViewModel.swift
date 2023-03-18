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
  var selectMeeting: AnyObserver<Int> { get }
  
  // Output
  var isSuccessCreateBoard: Signal<Int> { get }
}

final class CreateBoardViewModel: CreateBoardViewModelType {
  
  // Input
  let whichUpload: AnyObserver<BoardsRequest>
  let selectMeeting: AnyObserver<Int>
  
  // Output
  let isSuccessCreateBoard: Signal<Int>
  
  init() {
    let whichUploading = PublishSubject<BoardsRequest>()
    let whichPlubbingID = PublishSubject<Int>()
    
    self.whichUpload = whichUploading.asObserver()
    self.selectMeeting = whichPlubbingID.asObserver()
    
    // Input
    let createBoard = Observable.zip(
      whichPlubbingID,
      whichUploading
    )
      .flatMapLatest { plubbingID, request in
        return FeedsService.shared.createBoards(plubbingID: plubbingID, model: request)
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
