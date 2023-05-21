//
//  ActiveMeetingViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/27.
//

import Foundation

import RxSwift
import RxCocoa
import UIKit

protocol ActiveMeetingViewModelType {
  // MARK: Property
  var plubbingID: Int { get }
  var todoList: [TodoContent] { get }
  var feedList: [FeedsContent] { get }
  
  // MARK: Input
  var selectComplete: AnyObserver<Bool> { get }
  var selectPlubbingID: AnyObserver<Int> { get }
  var selectTodolistID: AnyObserver<Int> { get }
  var whichProofImage: AnyObserver<UIImage?> { get }
  var selectLikeButton: AnyObserver<Int> { get }
  
  // MARK: Output
  var meetingInfoDriver: Driver<RecruitingModel> { get } // 내 정보 데이터
  var reloadTaleViewDriver: Driver<Void> { get } // 테이블 뷰 리로드
}

final class ActiveMeetingViewModel {
  private let disposeBag = DisposeBag()
  
  // MARK: Property
  private(set) var plubbingID: Int
  private(set) var todoList = [TodoContent]()
  private(set) var feedList = [FeedsContent]()
  
  // MARK: UseCase
  private let inquireMyTodoUseCase: InquireMyTodoUseCase
  private let inquireMyFeedUseCase: InquireMyFeedUseCase
  
  // MARK: Subjects
  private let meetingInfoSubject = PublishSubject<RecruitingModel>()
  private let reloadTaleViewSubject = PublishSubject<Void>()
  private let selectingComplete = PublishSubject<Bool>()
  private let selectingPlubbingID = PublishSubject<Int>()
  private let selectingTodolistID = PublishSubject<Int>()
  private let allTodoTimeline = BehaviorSubject<[TodolistModel]>(value: [])
  private let completeTodolist = PublishSubject<CompleteProofTodolistResponse>()
  private let whichUploadingImage = PublishSubject<UIImage?>()
  private let selectingLikeButton = PublishSubject<Int>()
  
  init(
    plubbingID: Int,
    inquireMyTodoUseCase: InquireMyTodoUseCase,
    inquireMyFeedUseCase: InquireMyFeedUseCase
  ) {
    self.plubbingID = plubbingID
    self.inquireMyTodoUseCase = inquireMyTodoUseCase
    self.inquireMyFeedUseCase = inquireMyFeedUseCase
    
    fetchActiveMeetingData()
    tryCompleteTodolist()
    tryCancelCompleteTodolist()
    tryProofTodolist()
    tryLikeTodolist()
    
    selectingPlubbingID.onNext(plubbingID)
  }
  
  private func fetchActiveMeetingData(){
    let myTodo = inquireMyTodoUseCase
      .execute(plubbingID: plubbingID, cursorID: 0)
    let myFeed = inquireMyFeedUseCase
      .execute(plubbingID: plubbingID, cursorID: 0)
    
    Observable.zip(myTodo, myFeed)
      .subscribe(with: self) { owner, result in
        let (myTodoResult, myFeedResult) = result
        owner.handleMeetingInfo(plubbing: myTodoResult.plubbingInfo)
        owner.handleMyTodoInfo(todoInfo: myTodoResult.todoInfo)
        owner.handleMyFeedInfo(feedInfo: myFeedResult.feedInfo)
        owner.reloadTaleViewSubject.onNext(())
      }
      .disposed(by: disposeBag)
  }
  
  private func handleMeetingInfo(plubbing: PlubbingInfo) {
    meetingInfoSubject.onNext(
      RecruitingModel(
        title: plubbing.name,
        schedule: createScheduleString(
          days: plubbing.days,
          time: plubbing.time
        ),
        address: plubbing.address ?? "")
    )
  }
  
  private func handleMyTodoInfo(todoInfo: TodoInfo) {
    todoList = todoInfo.todoContent
      .prefix(2)
      .map { $0 }
  }
  
  private func handleMyFeedInfo(feedInfo: FeedInfo) {
    feedList = feedInfo.feedList
      .filter { $0.viewType != .system }
      .prefix(2)
      .map { $0 }
  }
  
  private func createScheduleString(days: [Day], time: String) -> String {
    let dateStr = days
      .map { $0.kor }
      .joined(separator: ", ")
    
    let date = DateFormatterFactory.dateTime
      .date(from: time) ?? Date()

    let timeStr = DateFormatterFactory.koreanTime
      .string(from: date)
    
    return (dateStr.isEmpty ? "온라인" : dateStr)  + " | " + timeStr
  }
  
  private func tryCompleteTodolist() {
    let completeTodolist = selectingComplete
      .filter { $0 }
      .withLatestFrom(
        Observable.combineLatest(
          selectingPlubbingID,
          selectingTodolistID
        )
      )
      .flatMapLatest(TodolistService.shared.completeTodolist)
      
    completeTodolist
      .withLatestFrom(selectingTodolistID) { ($0, $1) }
      .subscribe(with: self) { owner, response in
        let (result, todoID) = response
        Log.debug("완료 \(result) ")
        owner.changeTodoCheckState(todoID: todoID, state: true)
      }
    .disposed(by: disposeBag)
  }
  
  private func tryCancelCompleteTodolist() {
    let cancelCompleteTodolist = selectingComplete
      .filter { !$0 }
      .withLatestFrom(
        Observable.combineLatest(
          selectingPlubbingID,
          selectingTodolistID
        )
      )
      .flatMapLatest(TodolistService.shared.cancelCompleteTodolist)
    
    cancelCompleteTodolist
      .withLatestFrom(selectingTodolistID) { ($0, $1) }
      .subscribe(with: self) { owner, response in
        let (result, todoID) = response
        Log.debug("취소완료 \(result) ")
        owner.changeTodoCheckState(todoID: todoID, state: false)
      }
    .disposed(by: disposeBag)
  }
  
  private func getProofImage() -> Observable<String> { // 투두리스트 인증을 위한 이미지를 받아오는 함수
    let uploadImage = whichUploadingImage
      .compactMap { $0 }
      .flatMapLatest { image in
        ImageService.shared.uploadImage(
          images: [image],
          params: .init(type: .feed)
        )
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
    
    return tryImageToString.compactMap { $0 }
  }
  
  private func tryProofTodolist() { // 투두리스트 인증에 대한 API를 호출하는 함수
    let proofTodolist = Observable.combineLatest(
      selectingPlubbingID,
      selectingTodolistID,
      getProofImage().map { ProofTodolistRequest(proofImage: $0) }
    )
      .flatMapLatest(TodolistService.shared.proofTodolist)
    
    proofTodolist
      .subscribe(with: self) { owner, response in
        let changedModel = owner.todoList.map { element in
          guard let index = element.todoList.firstIndex(where: { $0.todoID == response.todoID }) else {
            return element
          }
          var element = element
          element.todoList[index].isProof = true
          return element
        }
        owner.todoList = changedModel
        owner.reloadTaleViewSubject.onNext(())
    }
    .disposed(by: disposeBag)
  }
  
  private func changeTodoCheckState(todoID: Int, state: Bool) {
    let changedModel = todoList.map { element in
      guard let index = element.todoList.firstIndex(where: { $0.todoID == todoID }) else {
        return element
      }
      var element = element
      element.todoList[index].isChecked = state
      return element
    }
    todoList = changedModel
    reloadTaleViewSubject.onNext(())
  }
  
  private func tryLikeTodolist() {
    let likeTodolist = selectingLikeButton
      .withLatestFrom(selectingPlubbingID) { ($0, $1) }
      .flatMapLatest { TodolistService.shared.likeTodolist(plubbingID: $1, timelineID: $0) }
    
    likeTodolist
      .withLatestFrom(selectingLikeButton) { ($0, $1) }
      .subscribe(with: self) { owner, response in
        let (result, timelineID) = response
        Log.debug("좋아요 응답값 \(result)")
        owner.changeTodoLikeState(timelineID: timelineID)
      }
    .disposed(by: disposeBag)
  }
  
  private func changeTodoLikeState(timelineID: Int) {
    let changedModel = todoList.map { element in
      guard element.todoID == timelineID else {
        return element
      }
      var element = element
      element.isLike = !element.isLike
      if element.isLike {
        element.totalLikes += 1
      } else {
        element.totalLikes -= 1
      }
      return element
    }
    todoList = changedModel
    reloadTaleViewSubject.onNext(())
  }
}


extension ActiveMeetingViewModel: ActiveMeetingViewModelType {
  // MARK: Input
  var selectPlubbingID: AnyObserver<Int> { // 선택한 plubbingID가 무엇인지
    selectingPlubbingID.asObserver()
  }
  
  var selectTodolistID: AnyObserver<Int> {
    selectingTodolistID.asObserver()
  }
  
  var selectComplete: AnyObserver<Bool> {
    selectingComplete.asObserver()
  }
  
  var whichProofImage: AnyObserver<UIImage?> {
    whichUploadingImage.asObserver()
  }
  
  var selectLikeButton: AnyObserver<Int> {
    selectingLikeButton.asObserver()
  }
  
  // MARK: Output
  var meetingInfoDriver: Driver<RecruitingModel> { meetingInfoSubject.asDriver(onErrorDriveWith: .empty())
  }
  
  var reloadTaleViewDriver: Driver<Void> { reloadTaleViewSubject.asDriver(onErrorDriveWith: .empty())
  }
}
