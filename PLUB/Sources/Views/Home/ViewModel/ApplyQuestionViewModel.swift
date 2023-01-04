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
  
  // Output
  var allQuestion: Driver<[ApplyQuestionTableViewCellModel]> { get }
}

class ApplyQuestionViewModel: ApplyQuestionViewModelType {
  private var disposeBag = DisposeBag()
  // Input
  
  // Output
  var allQuestion: Driver<[ApplyQuestionTableViewCellModel]>
  
  
  init() {
    let questions = BehaviorSubject<[ApplyQuestionTableViewCellModel]>(value: [])
    self.allQuestion = questions.asDriver(onErrorJustReturn: [])
    
    
    questions.onNext([
      .init(question: "1. 지원 동기가 궁금해요!", placeHolder: "소개하는 내용을 적어주세요"),
      .init(question: "2. 당신의 실력은 어느정도?!", placeHolder: "소개하는 내용을 적어주세요"),
      .init(question: "3. 간단한 자기소개! ", placeHolder: "소개하는 내용을 적어주세요")
    ])
    
    
  }
}
