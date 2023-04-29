//
//  CreateBoardViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/18.
//

import UIKit

import RxSwift
import RxCocoa

protocol CreateBoardViewModelType {
  // Input
  var selectMeeting: AnyObserver<Int> { get }
  var writeTitle: AnyObserver<String> { get }
  var writeContent: AnyObserver<String> { get }
  var isSelectImage: AnyObserver<Bool> { get }
  var whichPostType: AnyObserver<PostType> { get }
  var whichBoardImage: AnyObserver<UIImage?> { get }
  var tappedUploadButton: AnyObserver<Void> { get }
  
  // Output
  var isSuccessCreateBoard: Signal<Int> { get }
  var uploadButtonIsActivated: Driver<Bool> { get }
}

final class CreateBoardViewModel: CreateBoardViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let selectMeeting: AnyObserver<Int>
  let writeTitle: AnyObserver<String>
  let writeContent: AnyObserver<String>
  let isSelectImage: AnyObserver<Bool>
  let whichPostType: AnyObserver<PostType>
  let whichBoardImage: AnyObserver<UIImage?>
  let tappedUploadButton: AnyObserver<Void>
  
  // Output
  let isSuccessCreateBoard: Signal<Int>
  let uploadButtonIsActivated: Driver<Bool>
  
  init() {
    let whichUploadingRequest = PublishSubject<BoardsRequest>()
    let whichPlubbingID = PublishSubject<Int>()
    let whichUploadingImage = PublishSubject<UIImage?>()
    let writingTitle = BehaviorSubject<String>(value: "")
    let writingContent = BehaviorSubject<String>(value: "")
    let isSelectingImage = BehaviorSubject<Bool>(value: false)
    let isSuccessCreatingBoard = PublishRelay<Int>()
    let selectingPostType = BehaviorSubject<PostType>(value: .photo)
    let tappedUploadingButton = PublishSubject<Void>()
    
    tappedUploadButton = tappedUploadingButton.asObserver()
    whichBoardImage = whichUploadingImage.asObserver()
    selectMeeting = whichPlubbingID.asObserver()
    writeTitle = writingTitle.asObserver()
    writeContent = writingContent.asObserver()
    isSelectImage = isSelectingImage.asObserver()
    whichPostType = selectingPostType.asObserver()
    
    // Input
    
    let titleExceptPlaceholder = writingTitle
      .filter { $0 != Constants.titlePlaceholder }
    
    let contentExceptPlaceholder = writingContent
      .filter { $0 != Constants.contentPlaceholder }
    
    let titleNotEmpty = titleExceptPlaceholder
      .map { !$0.isEmpty }
    
    let contentNotEmpty = contentExceptPlaceholder
      .map { !$0.isEmpty }
    
    let uploadImage = whichUploadingImage
      .compactMap { $0 }
      .flatMapLatest { image in
        ImageService.shared.uploadImage(images: [image], params: .init(type: .feed))
      }
    
    let tryImageToString = uploadImage
      .flatMap { response -> Observable<String?> in
        switch response {
        case let .success(imageModel):
          return .just(imageModel.data?.files.first?.fileURL)
        default:
          // 이미지 등록이 되지 못함 (오류 발생)
          return .empty()
        }
      }
    
    tappedUploadingButton
      .withLatestFrom(selectingPostType)
      .flatMap { type in
        switch type {
        case .photo:
          return Observable.combineLatest(
            titleExceptPlaceholder,
            tryImageToString
          ) { title, feedImage in
            return BoardsRequest(title: title, content: nil, feedImage: feedImage)
          }
        case .text:
          return Observable.combineLatest(
            titleExceptPlaceholder,
            contentExceptPlaceholder
          ) { title, content in
            return BoardsRequest(title: title, content: content, feedImage: nil)
          }
        case .photoAndText:
          return Observable.combineLatest(
            titleExceptPlaceholder,
            contentExceptPlaceholder,
            tryImageToString
          ) { title, content, feedImage in
            return BoardsRequest(title: title, content: content, feedImage: feedImage)
          }
        }
      }
      .subscribe(onNext: { request in
        whichUploadingRequest.onNext(request)
      })
      .disposed(by: disposeBag)
    
    let createBoard = Observable.combineLatest(
      whichPlubbingID,
      whichUploadingRequest
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
    
    uploadButtonIsActivated = selectingPostType
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
