//
//  ApplyQuestionViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/04.
//

import RxSwift
import RxCocoa

// 모든 질문에 관련된 상태값을 저장해서 이걸 확인하고 같지않으면 내보내는 방식으로 해야할듯
protocol ApplyQuestionViewModelType {
  // Input
  var whichQuestion: AnyObserver<QuestionStatus> { get }
  var whichRecruitment: AnyObserver<String> { get }
  
  // Output
  var allQuestion: Driver<[ApplyQuestionTableViewCellModel]> { get }
  var isActivated: Driver<Bool> { get }
}

final class ApplyQuestionViewModel: ApplyQuestionViewModelType {
  private let disposeBag = DisposeBag()
  // Input
  let whichQuestion: AnyObserver<QuestionStatus> // 어떤 질문에 대한 상태값이 변경됬는지
  let whichRecruitment: AnyObserver<String> // 지원질문조회를 위한 어떤 모집에 대한 ID인지
  
  // Output
  let allQuestion: Driver<[ApplyQuestionTableViewCellModel]> // 특정 ID에 해당하는 모집에 관련된 질문 데이터
  let isActivated: Driver<Bool> // [지원하기]버튼의 사용가능 유무
  
  init() {
    let currentPlubbing = PublishSubject<String>()
    let questions = BehaviorSubject<[ApplyQuestionTableViewCellModel]>(value: [])
    let currentQuestion = PublishSubject<QuestionStatus>()
    let isActivating = BehaviorSubject<Bool>(value: false)
    let entireQuestionStatus = PublishSubject<[QuestionStatus]>()
    
    self.whichRecruitment = currentPlubbing.asObserver()
    self.allQuestion = questions.asDriver(onErrorJustReturn: [])
    self.whichQuestion = currentQuestion.asObserver()
    self.isActivated = isActivating.asDriver(onErrorJustReturn: false)
    
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
  
  static func == (lhs: QuestionStatus, rhs: QuestionStatus) -> Bool {
    return lhs.id == rhs.id && lhs.isFilled == rhs.isFilled
  }
}
