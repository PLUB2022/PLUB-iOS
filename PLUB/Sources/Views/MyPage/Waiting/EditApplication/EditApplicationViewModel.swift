//
//  EditApplicationViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/19.
//

import Foundation

import RxSwift
import RxCocoa

final class EditApplicationViewModel {
  private let disposeBag = DisposeBag()
  private let plubbingID: Int
  
  // Input
  let answerText: AnyObserver<[Answer]>
  let editButtonTapped: AnyObserver<Void>
  
  // Output
  let editButtonEnabled: Driver<Bool>
  
  private let answerSubject = PublishSubject<[Answer]>()
  private let editButtonTappedSubject = PublishSubject<Void>()
  
  init(plubbingID: Int) {
    self.plubbingID = plubbingID
    
    answerText = answerSubject.asObserver()
    editButtonTapped = editButtonTappedSubject.asObserver()
    
    editButtonEnabled = answerSubject
      .map { $0.map { $0.answer } }
      .map { !$0.contains("") }
      .asDriver(onErrorDriveWith: .empty())
    
    editButtonTappedSubject
      .withLatestFrom(answerSubject)
      .withUnretained(self)
      .subscribe(onNext: { owner, anwers in
        let applyAnswer = anwers.map {
          ApplyAnswer(questionID: $0.questionID, answer: $0.answer)
        }
        owner.editApplication(answer: applyAnswer)
      })
      .disposed(by: disposeBag)
  }
  
  private func editApplication(answer: [ApplyAnswer]) {
    RecruitmentService.shared.editApplication(
      plubbingID: plubbingID,
      request: ApplyForRecruitmentRequest(answers: answer)
    )
    .withUnretained(self)
    .subscribe(onNext: { owner, _ in
      
    })
    .disposed(by: disposeBag)
  }
}
