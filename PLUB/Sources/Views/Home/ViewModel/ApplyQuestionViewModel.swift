//
//  ApplyQuestionViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/04.
//

import RxSwift
import RxCocoa
import Foundation

// TODO: 이건준 - combineLatest이용하여 지원질문화면 Active에 따른 isActive 데이터처리해줘야함

protocol ApplyQuestionViewModelType {
  // Input
  var isFillInQuestion: AnyObserver<Bool> { get }
  var whichPosition: AnyObserver<IndexPath> { get }
  
  // Output
  var allQuestion: Driver<[ApplyQuestionTableViewCellModel]> { get }
//  var isActive: Driver<Bool> { get }
}

class ApplyQuestionViewModel: ApplyQuestionViewModelType {
  private var disposeBag = DisposeBag()
  // Input
  var isFillInQuestion: AnyObserver<Bool>
  var whichPosition: AnyObserver<IndexPath>
  
  // Output
  var allQuestion: Driver<[ApplyQuestionTableViewCellModel]>
//  var isActive: Driver<Bool>
  
  init() {
    let questions = BehaviorSubject<[ApplyQuestionTableViewCellModel]>(value: [])
    let writingCount = BehaviorSubject<Int>(value: 0)
    let isFillingInQuestion = BehaviorSubject<Bool>(value: false)
    let currentPosition = PublishSubject<IndexPath>()
    let questionStatus = PublishSubject<[QuestionStatus]>()
    
    self.allQuestion = questions.asDriver(onErrorJustReturn: [])
    self.isFillInQuestion = isFillingInQuestion.asObserver()
    self.whichPosition = currentPosition.asObserver()
    let entireQuestionCount = questions.map { $0.count }
    let currentPositonRow = currentPosition.map { $0.row }
    
    
    Observable.combineLatest(
      isFillingInQuestion,
      currentPositonRow
    ) { ($0, $1) }
      .distinctUntilChanged { $0 == $1 }
      .subscribe(onNext: { isFill, position in
        print("isFill = \(isFill)")
        print("position = \(position)")
      })
      .disposed(by: disposeBag)
    
//    isFillingInQuestion
//      .distinctUntilChanged()
//      .filter { $0 == true }
//      .withLatestFrom(writingCount.asObservable())
//      .subscribe(onNext: { count in
//          writingCount.onNext(count + 1)
//          print("plus = \(count + 1)")
//        }
//      )
//      .disposed(by: disposeBag)

    questions.onNext([
      .init(id: 1,question: "1. 지원 동기가 궁금해요!"),
      .init(id: 2,question: "2. 당신의 실력은 어느정도?!"),
      .init(id: 3,question: "3. 간단한 자기소개! ")
    ])
  }
}
