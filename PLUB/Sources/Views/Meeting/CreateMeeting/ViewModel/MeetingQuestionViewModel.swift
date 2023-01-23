//
//  MeetingQuestionViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/23.
//

import RxSwift
import RxRelay

struct MeetingQuestionCellModel {
  let question: String
  let isFilled: Bool
}

final class MeetingQuestionViewModel {
  private let disposeBag = DisposeBag()
  
  // Input
  var questionList: [String]
  let questionListBehaviorRelay: BehaviorRelay<[MeetingQuestionCellModel]>
  
  // Output
  let allQuestionFilled = PublishRelay<Bool>()
  
  init() {
    questionList = [""]
    questionListBehaviorRelay = .init(value: [MeetingQuestionCellModel(question: "", isFilled: false)])
    
    questionListBehaviorRelay
      .map { $0.map { $0.isFilled } }
      .map { !$0.contains(false) }
      .distinctUntilChanged()
      .bind(to: allQuestionFilled)
      .disposed(by: disposeBag)
  }
  
  func updateQuestion(index: Int, data: MeetingQuestionCellModel) {
    var oldData = questionListBehaviorRelay.value
    oldData[index] = data
    questionListBehaviorRelay.accept(oldData)
  }
  
  func removeQuestion(index: Int) {
    var oldData = questionListBehaviorRelay.value
    oldData.remove(at: index)
    questionListBehaviorRelay.accept(oldData)
    
    questionList = oldData.map {$0.question}
  }
  
  func addQuestion() {
    var oldData = questionListBehaviorRelay.value
    oldData.append(MeetingQuestionCellModel(question: "", isFilled: false))
    questionListBehaviorRelay.accept(oldData)
  }
}
