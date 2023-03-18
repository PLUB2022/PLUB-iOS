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
  
  // Output
  var isSuccessCreateBoard: Signal<Int> { get }
  var onlyTextUploadButtonIsActivated: Driver<Bool> { get }
  var photoAndTextUploadButtonIsActivated: Driver<Bool> { get }
  var onlyPhotoUploadButtonIsActivated: Driver<Bool> { get }
}

final class CreateBoardViewModel: CreateBoardViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let whichUpload: AnyObserver<BoardsRequest>
  let selectMeeting: AnyObserver<Int>
  let writeTitle: AnyObserver<String>
  let writeContent: AnyObserver<String>
  let isSelectImage: AnyObserver<Bool>
  
  // Output
  let isSuccessCreateBoard: Signal<Int>
  let onlyTextUploadButtonIsActivated: Driver<Bool>
  let photoAndTextUploadButtonIsActivated: Driver<Bool>
  let onlyPhotoUploadButtonIsActivated: Driver<Bool>
  
  init() {
    let whichUploading = PublishSubject<BoardsRequest>()
    let whichPlubbingID = PublishSubject<Int>()
    let writingTitle = BehaviorSubject<String>(value: "")
    let writingContent = BehaviorSubject<String>(value: "")
    let isSelectingImage = BehaviorSubject<Bool>(value: false)
    
    self.whichUpload = whichUploading.asObserver()
    self.selectMeeting = whichPlubbingID.asObserver()
    self.writeTitle = writingTitle.asObserver()
    self.writeContent = writingContent.asObserver()
    self.isSelectImage = isSelectingImage.asObserver()
    
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
    
    onlyTextUploadButtonIsActivated = Observable.combineLatest(
      writingTitle
        .filter { $0 != Constants.titlePlaceholder },
      writingContent
        .filter { $0 != Constants.contentPlaceholder }
    ) { ($0, $1) }
      .map { !$0.isEmpty && !$1.isEmpty }
      .asDriver(onErrorDriveWith: .empty())
    
    photoAndTextUploadButtonIsActivated = Observable.combineLatest(
      writingTitle
        .filter { $0 != Constants.titlePlaceholder },
      writingContent
        .filter { $0 != Constants.contentPlaceholder },
      isSelectingImage
    ) { ($0, $1, $2) }
      .map { !$0.isEmpty && !$1.isEmpty && $2 }
      .asDriver(onErrorDriveWith: .empty())
    
    onlyPhotoUploadButtonIsActivated = Observable.combineLatest(
      writingTitle
        .filter { $0 != Constants.titlePlaceholder },
      isSelectingImage
    ) { ($0, $1) }
      .map { !$0.isEmpty && $1 }
      .asDriver(onErrorDriveWith: .empty())
    
  }
}

extension CreateBoardViewModel {
  struct Constants {
    static let titlePlaceholder = "제목을 입력해주세요"
    static let contentPlaceholder = "내용을 입력해주세요"
  }
}
