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
  var writeTitle: AnyObserver<String> { get }
  var writeContent: AnyObserver<String> { get }
  var isSelectImage: AnyObserver<Bool> { get }
  var whichPostType: AnyObserver<PostType> { get }
  
  // Output
  var isSuccessCreateBoard: Signal<Int> { get }
  var uploadButtonIsActivated: Driver<Bool> { get }
}

final class CreateBoardViewModel: CreateBoardViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let whichUpload: AnyObserver<BoardsRequest>
  let selectMeeting: AnyObserver<Int>
  let writeTitle: AnyObserver<String>
  let writeContent: AnyObserver<String>
  let isSelectImage: AnyObserver<Bool>
  let whichPostType: AnyObserver<PostType>
  
  // Output
  let isSuccessCreateBoard: Signal<Int>
  let uploadButtonIsActivated: Driver<Bool>
  
  init() {
    let whichUploading = PublishSubject<BoardsRequest>()
    let whichPlubbingID = PublishSubject<Int>()
    let writingTitle = BehaviorSubject<String>(value: "")
    let writingContent = BehaviorSubject<String>(value: "")
    let isSelectingImage = BehaviorSubject<Bool>(value: false)
    let isSuccessCreatingBoard = PublishRelay<Int>()
    let selectingPostType = BehaviorSubject<PostType>(value: .photo)
    
    whichUpload = whichUploading.asObserver()
    selectMeeting = whichPlubbingID.asObserver()
    writeTitle = writingTitle.asObserver()
    writeContent = writingContent.asObserver()
    isSelectImage = isSelectingImage.asObserver()
    whichPostType = selectingPostType.asObserver()
    
    // Input
    let createBoard = Observable.zip(
      whichPlubbingID,
      whichUploading
    )
      .flatMapLatest { plubbingID, request in
        return FeedsService.shared.createBoards(plubbingID: plubbingID, model: request)
      }
    
    createBoard
      .subscribe(onNext: { data in
        isSuccessCreatingBoard.accept(data.feedID)
      })
      .disposed(by: disposeBag)
    
    // Output
    isSuccessCreateBoard = isSuccessCreatingBoard
      .asSignal(onErrorSignalWith: .empty())
    
    let titleNotEmpty = writingTitle
      .filter { $0 != Constants.titlePlaceholder }
      .map { !$0.isEmpty }
    
    let contentNotEmpty = writingContent
      .filter { $0 != Constants.contentPlaceholder }
      .map { !$0.isEmpty }
    
    let postType = selectingPostType
      .share()
    
    uploadButtonIsActivated = postType
      .flatMap { type in
        switch type {
        case .photo:
          return Observable.combineLatest(
            titleNotEmpty,
            isSelectingImage
          )
          .map { $0 && $1 }
        case .text:
          return Observable.combineLatest(
            titleNotEmpty,
            contentNotEmpty
          )
          .map { $0 && $1 }
        case .photoAndText:
          return Observable.combineLatest(
            titleNotEmpty,
            contentNotEmpty,
            isSelectingImage
          )
          .map { $0 && $1 && $2 }
        }
      }
      .asDriver(onErrorDriveWith: .empty())
    
  }
}

extension CreateBoardViewModel {
  struct Constants {
    static let titlePlaceholder = "제목을 입력해주세요"
    static let contentPlaceholder = "내용을 입력해주세요"
  }
}
