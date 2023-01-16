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
  
  // Output
  var allQuestion: Driver<[ApplyQuestionTableViewCellModel]> { get }
  var isActivated: Driver<Bool> { get }
}

class ApplyQuestionViewModel: ApplyQuestionViewModelType {
  private var disposeBag = DisposeBag()
  // Input
  var whichQuestion: AnyObserver<QuestionStatus>
  
  // Output
  var allQuestion: Driver<[ApplyQuestionTableViewCellModel]>
  var isActivated: Driver<Bool>
  
  init() {
    let questions = BehaviorSubject<[ApplyQuestionTableViewCellModel]>(value: [])
    let writingCount = BehaviorSubject<Int>(value: 0)
    let currentQuestion = PublishSubject<QuestionStatus>()
    let isActivating = BehaviorSubject<Bool>(value: false)
    let entireQuestionStatus = PublishSubject<[QuestionStatus]>()
    
    self.allQuestion = questions.asDriver(onErrorJustReturn: [])
    self.whichQuestion = currentQuestion.asObserver()
    self.isActivated = isActivating.asDriver(onErrorJustReturn: false)
    
    // 받아온 질문들을 초기화된 각각의 textView에 대한 상태값을 저장
    questions.map { questionModels in
      questionModels.map { questionModel -> QuestionStatus in
        return QuestionStatus(id: questionModel.id, isFilled: false)
      }
    }
    .bind(to: entireQuestionStatus)
    .disposed(by: disposeBag)
    
    currentQuestion.distinctUntilChanged().withLatestFrom(entireQuestionStatus) { ($0, $1) }
      .subscribe(onNext: { (currentStatus, entireStatus) in
        let entireStatus = entireStatus.map { status -> QuestionStatus in
          if status.id == currentStatus.id {
            return QuestionStatus(id: status.id, isFilled: currentStatus.isFilled)
          } else {
            return QuestionStatus(id: currentStatus.id, isFilled: currentStatus.isFilled)
          }
        }
        print("ststs = \(entireStatus)")
        entireQuestionStatus.onNext(entireStatus)
      })
      .disposed(by: disposeBag)
    
    let entireQuestionCount = questions.map { $0.count }
    
    Observable.combineLatest(writingCount, entireQuestionStatus) { ($0, $1) }
      .map { (questionStatus, entireQuestionStatus) in
            
      }
    
    entireQuestionStatus.subscribe(onNext: { entire in
      print("entire = \(entire)")
    })
    .disposed(by: disposeBag)
//    let checkStatus = currentQuestion.withLatestFrom(entireQuestionStatus) { ($0, $1) }
//      .map { (currentStatus, entireStatus) in
//        entireStatus.filter { status in
//          return currentStatus == status
//        }
//      }
      
    
    let plusCount = entireQuestionStatus.distinctUntilChanged()
      .withLatestFrom(writingCount) { ($0, $1) }
      .filter({ (entireStatus, count) in
        print("오잉 = \(entireStatus)")
        for status in entireStatus {
          if status.isFilled {
            return true
          }
        }
        return false
      })
      .map { $0.1 + 1 }
    
    let checkAllTrue = entireQuestionStatus.filter { entireStatus in
      if entireStatus.contains(where: { !$0.isFilled }) {
        return false
      }
      return true
    }
    
    checkAllTrue.map { $0.count != 0 }
      .bind(to: isActivating)
      .disposed(by: disposeBag)
    
//    let plusCount = currentQuestion.distinctUntilChanged()
//      .withLatestFrom(writingCount) { ($0, $1) }
//      .filter { $0.0.isFilled }
//      .map { $0.1 + 1 }
    
//    let minusCount = currentQuestion.distinctUntilChanged()
//      .withLatestFrom(writingCount) { ($0, $1) }
//      .filter { !$0.0.isFilled }
//      .map { $0.1 - 1 }
    
//    Observable.merge(plusCount, minusCount)
//      .bind(to: writingCount)
//      .disposed(by: disposeBag)
//
//    Observable.combineLatest(writingCount, entireQuestionCount) { ($0, $1) }
//      .map { $0.0 == $0.1 }
//      .bind(to: isActivating)
//      .disposed(by: disposeBag)
    
    currentQuestion.distinctUntilChanged().subscribe(onNext: { current in
      print("current = \(current)")
    })
    .disposed(by: disposeBag)
    
    writingCount.subscribe(onNext: { count in
      print("count = \(count)")
    })
    .disposed(by: disposeBag)
    
    questions.onNext([
      .init(id: 1,question: "1. 지원 동기가 궁금해요!"),
      .init(id: 2,question: "2. 당신의 실력은 어느정도?!"),
      .init(id: 3,question: "3. 간단한 자기소개! ")
    ])
  }
}

struct QuestionStatus: Equatable {
  let id: Int
  let isFilled: Bool
  
  static func == (lhs: QuestionStatus, rhs: QuestionStatus) -> Bool {
    return lhs.id == rhs.id && lhs.isFilled == rhs.isFilled
  }
}
