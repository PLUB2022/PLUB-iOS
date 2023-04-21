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
  
  private let editApplicationUseCase: EditApplicationUseCase
  
  // Input
  let answerText: AnyObserver<[Answer]>
  let editButtonTapped: AnyObserver<Void>
  
  // Output
  let editButtonEnabled: Driver<Bool>
  let successEditApplication: Driver<Void>
  
  private let answerSubject = PublishSubject<[Answer]>()
  private let editButtonTappedSubject = PublishSubject<Void>()
  private let successEditApplicationSubject = PublishSubject<Void>()
  
  init(
    plubbingID: Int,
    editApplicationUseCase: EditApplicationUseCase
  ) {
    self.plubbingID = plubbingID
    self.editApplicationUseCase = editApplicationUseCase
    
    answerText = answerSubject.asObserver()
    editButtonTapped = editButtonTappedSubject.asObserver()
    
    successEditApplication = successEditApplicationSubject.asDriver(onErrorDriveWith: .empty())
    
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
    editApplicationUseCase
      .execute(
        plubbingID: plubbingID,
        answer: answer
      )
      .bind(to: successEditApplicationSubject)
      .disposed(by: disposeBag)
  }
}
