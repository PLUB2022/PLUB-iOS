//
//  TodolistService.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/28.
//

import RxSwift

final class TodolistService: BaseService {
  static let shared = TodolistService()
  
  private override init() { }
}

extension TodolistService {
  
  /// 전체타임라인을 조회합니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - cursorID: 타임라인 페이징을 위한 커서 ID
  func inquireAllTodoTimeline(plubbingID: Int, cursorID: Int = 0) -> PLUBResult<PaginatedDataResponse<InquireAllTodoTimelineResponse>> {
    sendRequest(
      TodolistRouter.inquireAllTodoTimeline(plubbingID, cursorID),
      type: PaginatedDataResponse<InquireAllTodoTimelineResponse>.self
    )
  }
  
  /// 투두 상세조회합니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - timelineID: 투두에 해당하는 타임라인 ID
  func inquireTodolist(plubbingID: Int, timelineID: Int) -> Observable<InquireTodolistResponse> {
    sendObservableRequest(TodolistRouter.inquireTodolist(plubbingID, timelineID))
  }
  
  /// 투두리스트 완료요청합니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - todolistID: 투두리스트 ID
  func completeTodolist(plubbingID: Int, todolistID: Int) -> Observable<CompleteProofTodolistResponse> {
    sendObservableRequest(TodolistRouter.completeTodolist(plubbingID, todolistID))
  }
  
  /// 투두리스트 완료취소요청합니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - todolistID: 투두리스트 ID
  func cancelCompleteTodolist(plubbingID: Int, todolistID: Int) -> Observable<CompleteProofTodolistResponse> {
    sendObservableRequest(TodolistRouter.cancelCompleteTodolist(plubbingID, todolistID))
  }
  
  /// 투두리스트 인증요청합니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - todolistID: 투두리스트 ID
  ///   - request: 인증을 위한 이미지 요청모델
  func proofTodolist(plubbingID: Int, todolistID: Int, request: ProofTodolistRequest) -> Observable<CompleteProofTodolistResponse> {
    sendObservableRequest(TodolistRouter.proofTodolist(plubbingID, todolistID, request))
  }
  
  /// 투두리스트 좋아요/좋아요 취소 요청합니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - timelineID: 타임라인 ID
  func likeTodolist(plubbingID: Int, timelineID: Int) -> Observable<LikeTodolistResponse> {
    sendObservableRequest(TodolistRouter.likeTodolist(plubbingID, timelineID))
  }
  
  func createTodo(plubbingID: Int, request: CreateTodoRequest) -> Observable<CreateTodoResponse> {
    sendObservableRequest(TodolistRouter.createTodo(plubbingID, request))
  }
  
  func inquireTodolistByDate(plubbingID: Int, todoDate: String) -> Observable<InquireTodolistByDateResponse> {
    sendObservableRequest(TodolistRouter.inquireTodolistByDate(plubbingID, todoDate))
  }
}
