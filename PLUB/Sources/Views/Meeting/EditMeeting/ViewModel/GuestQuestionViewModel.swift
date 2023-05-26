//
//  GuestQuestionViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/11.
//

import RxSwift
import RxCocoa

final class GuestQuestionViewModel {
  
  private let disposeBag = DisposeBag()
  private let plubbingID: Int
  
  // Input
  var questionList: [String]
  let questionListBehaviorRelay: BehaviorRelay<[MeetingQuestionCellModel]>
  let noQuestionMode: BehaviorRelay<Bool>
  
  // Output
  let fetchedMeetingData = PublishSubject<Void>()
  let allQuestionFilled: BehaviorRelay<Bool>
  let successEditQuestion = PublishSubject<Void>()
  
  init(plubbingID: Int) {
    self.plubbingID = plubbingID
    
    questionList = [""]
    questionListBehaviorRelay = .init(value: [MeetingQuestionCellModel(question: "", isFilled: false)])
    noQuestionMode = .init(value: false)
    allQuestionFilled = .init(value: false)
    
    questionListBehaviorRelay
      .map { $0.map { $0.isFilled } }
      .map { !$0.contains(false) }
      .distinctUntilChanged()
      .bind(to: allQuestionFilled)
      .disposed(by: disposeBag)
  }
  
  func fetchMeetingData() {
    RecruitmentService.shared.inquireRecruitmentQuestion(plubbingID: plubbingID)
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          guard let data = model.data else { return }
          owner.setupMeetingData(data: data)
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func setupMeetingData(data: RecruitmentQuestionResponse) {
    if data.questions.isEmpty {
      noQuestionMode.accept(true)
    } else {
      noQuestionMode.accept(false)
      
      questionListBehaviorRelay.accept(
        data.questions.map {
          MeetingQuestionCellModel(
            question: $0.question,
            isFilled: true
          )
        }
      )
      
      questionList = data.questions.map {
        $0.question
      }
    }
    fetchedMeetingData.onNext(())
  }
  
  func updateQuestion(index: Int, data: MeetingQuestionCellModel) {
    var oldData = questionListBehaviorRelay.value
    oldData[index] = data
    questionListBehaviorRelay.accept(oldData)
    
    questionList = oldData.map {$0.question}
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
    
    questionList = oldData.map {$0.question}
  }
  
  func requestEditMeeting() {
    RecruitmentService.shared
      .editMeetingQuestion(
        plubbingID: plubbingID,
        request: setupEditMeetingRequest()
      )
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(_):
          owner.successEditQuestion.onNext(())
        default: break// TODO: 수빈 - PLUB 에러 Alert 띄우기
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func setupEditMeetingRequest() -> EditMeetingQuestionRequest{
    if noQuestionMode.value {
      return EditMeetingQuestionRequest(questions: [])
    } else {
      return EditMeetingQuestionRequest(questions: questionList)
    }
  }
}
