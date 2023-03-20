//
//  ApplyQuestionViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/04.
//

import RxSwift
import RxCocoa

protocol ApplyQuestionViewModelType {
  // Input
  var whichQuestion: AnyObserver<QuestionStatus> { get }
  var whichRecruitment: AnyObserver<String> { get }
  var whichApplyRequest: AnyObserver<ApplyForRecruitmentRequest> { get }
  
  // Output
  var allQuestion: Driver<[ApplyQuestionTableViewCellModel]> { get }
  var isActivated: Driver<Bool> { get }
}

// TODO: 이건준 -추후 API요청에 따른 result failure에 대한 에러 묶어서 처리하기
final class ApplyQuestionViewModel: ApplyQuestionViewModelType {
  private let disposeBag = DisposeBag()
  // Input
  let whichQuestion: AnyObserver<QuestionStatus> // 어떤 질문에 대한 상태값이 변경됬는지
  let whichRecruitment: AnyObserver<String> // 지원질문조회를 위한 어떤 모집에 대한 ID인지
  let whichApplyRequest: AnyObserver<ApplyForRecruitmentRequest> // 어떤 질문에 대한 답변을 입력할 것인지
  
  // Output
  let allQuestion: Driver<[ApplyQuestionTableViewCellModel]> // 특정 ID에 해당하는 모집에 관련된 질문 데이터
  let isActivated: Driver<Bool> // [지원하기]버튼의 사용가능 유무
  
  init() {
    let currentPlubbing = PublishSubject<String>()
    let questions = BehaviorRelay<[ApplyQuestionTableViewCellModel]>(value: [])
    let currentQuestion = PublishSubject<QuestionStatus>()
    let isActivating = BehaviorSubject<Bool>(value: false)
    let entireQuestionStatus = PublishSubject<[QuestionStatus]>()
    let whichApplyingRequest = PublishSubject<ApplyForRecruitmentRequest>()
    let entireApplyRequest = BehaviorRelay<[ApplyForRecruitmentRequest]>(value: [])
    
    whichRecruitment = currentPlubbing.asObserver()
    allQuestion = questions.asDriver(onErrorJustReturn: [])
    whichQuestion = currentQuestion.asObserver()
    isActivated = isActivating.asDriver(onErrorJustReturn: false)
    whichApplyRequest = whichApplyingRequest.asObserver()
    
    whichApplyingRequest
      .subscribe(onNext: { request in
        var entire = entireApplyRequest.value
        if !entire.contains(request) {
          print("겹치지않아요")
          entire.append(request)
          entireApplyRequest.accept(entire)
        } else {
          print("겹쳐요")
          var filterEntire = entire.filter { $0 != request }
          filterEntire.append(request)
          entireApplyRequest.accept(filterEntire)
        }
      })
      .disposed(by: disposeBag)
    
    /// 받아온 질문들을 초기화된 각각의 textView에 대한 상태값을 저장
    questions.map { questionModels in
      questionModels.map { questionModel -> QuestionStatus in
        return QuestionStatus(id: questionModel.id, isFilled: false)
      }
    }
    .bind(to: entireQuestionStatus)
    .disposed(by: disposeBag)
    
    /// 특정 질문에 관련된 상태값이 변경될때마다 해당 질문에 대한 정보를 변경
    currentQuestion.distinctUntilChanged().withLatestFrom(entireQuestionStatus) { ($0, $1) }
      .subscribe(onNext: { (currentStatus, entireStatus) in
        let entireStatus = entireStatus.map { status -> QuestionStatus in
          if status.id == currentStatus.id {
            return QuestionStatus(id: currentStatus.id, isFilled: currentStatus.isFilled)
          } else {
            return QuestionStatus(id: status.id, isFilled: status.isFilled)
          }
        }
        entireQuestionStatus.onNext(entireStatus)
      })
      .disposed(by: disposeBag)
    
    entireQuestionStatus
      .distinctUntilChanged()
      .subscribe(onNext: { current in
        let isAllChecked = current.filter{ $0.isFilled == false }.count == 0
        isActivating.onNext(isAllChecked)
      })
      .disposed(by: disposeBag)
    
    let fetchingQuestions = currentPlubbing
      .flatMapLatest(RecruitmentService.shared.inquireRecruitmentQuestion(plubbingID: ))
    
    let successFetching = fetchingQuestions.compactMap { result -> RecruitmentQuestionResponse? in
      guard case .success(let response) = result else { return nil }
      return response.data
    }
    
    successFetching.map { response in
      let data = response.questions.map { question in
        return ApplyQuestionTableViewCellModel(id: question.id, question: question.question)
      }
      return data
    }
    .bind(to: questions)
    .disposed(by: disposeBag)
  }
}

struct QuestionStatus: Equatable {
  let id: Int
  let isFilled: Bool
}
