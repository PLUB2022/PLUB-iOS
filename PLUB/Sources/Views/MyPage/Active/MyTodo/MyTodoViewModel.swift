//
//  MyTodoViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/05/14.
//

import UIKit

import RxSwift
import RxCocoa

protocol MyTodoViewModelType {
  // MARK: Property
  var plubbingID: Int { get }
  var plubbingTitle: String { get }
  var todoList: [TodoContent] { get }
  
  // MARK: Input
  var offsetObserver: AnyObserver<(tableViewHeight: CGFloat, offset: CGFloat)> { get }
  var selectComplete: AnyObserver<Bool> { get }
  var selectPlubbingID: AnyObserver<Int> { get }
  var selectTodolistID: AnyObserver<Int> { get }
  var whichProofImage: AnyObserver<UIImage?> { get }
  var selectLikeButton: AnyObserver<Int> { get }
  
  // MARK: Output
  var reloadTaleViewDriver: Driver<Void> { get } // 테이블 뷰 리로드
}

final class MyTodoViewModel {
  private let disposeBag = DisposeBag()
  
  // MARK: Property
  private(set) var plubbingID: Int
  private(set) var plubbingTitle: String
  private(set) var todoList = [TodoContent]()
  private let pagingManager = PagingManager<TodoContent>(threshold: 700)
  
  // MARK: UseCase
  private let inquireMyTodoUseCase: InquireMyTodoUseCase
  
  // MARK: Subjects
  private let offsetSubject = PublishSubject<(tableViewHeight: CGFloat, offset: CGFloat)>()
  private let selectingPlubbingID = PublishSubject<Int>()
  private let selectingComplete = PublishSubject<Bool>()
  private let selectingTodolistID = PublishSubject<Int>()
  private let whichUploadingImage = PublishSubject<UIImage?>()
  private let selectingLikeButton = PublishSubject<Int>()
  private let reloadTaleViewSubject = PublishSubject<Void>()
  
  init(
    plubbingID: Int,
    plubbingTitle: String,
    inquireMyTodoUseCase: InquireMyTodoUseCase
  ) {
    self.plubbingID = plubbingID
    self.plubbingTitle = plubbingTitle
    self.inquireMyTodoUseCase = inquireMyTodoUseCase
    
    pagingSetup(plubbingID: plubbingID)
    tryCompleteTodolist()
    tryCancelCompleteTodolist()
    tryProofTodolist()
    tryLikeTodolist()
    
    selectingPlubbingID.onNext(plubbingID)
  }
  
  private func pagingSetup(plubbingID: Int) {
    offsetSubject
      .filter { [pagingManager] in
        return pagingManager.shouldFetchNextPage(totalHeight: $0, offset: $1)
      }
      .flatMap { [weak self] _ -> Observable<[TodoContent]> in
        guard let self else { return .empty() }
        return self.pagingManager.fetchNextPage { cursorID in
          self.inquireMyTodoUseCase.execute(plubbingID: plubbingID, cursorID: cursorID)
            .map { data in
              (
                content: data.todoInfo.todoContent,
                nextCursorID: data.todoInfo.todoContent.last?.todoID ?? 0,
                isLast: data.todoInfo.isLast
              )
            }
        }
      }
      .subscribe(with: self) { owner, content in
        owner.todoList.append(contentsOf: content)
        owner.reloadTaleViewSubject.onNext(())
      }
      .disposed(by: disposeBag)
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

extension MyTodoViewModel: MyTodoViewModelType {
  // MARK: Input
  var offsetObserver: AnyObserver<(tableViewHeight: CGFloat, offset: CGFloat)> {
    offsetSubject.asObserver()
  }
  
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
  var reloadTaleViewDriver: Driver<Void> { reloadTaleViewSubject.asDriver(onErrorDriveWith: .empty())
  }
}
