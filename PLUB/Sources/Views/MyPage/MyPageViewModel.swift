//
//  MyPageViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/12.
//

import UIKit

import RxSwift
import RxCocoa

final class MyPageViewModel {
  private let disposeBag = DisposeBag()
  
  // Output
  let myInfo: Driver<MyInfoResponse>
  
  private let myInfoSubject = PublishSubject<MyInfoResponse>()
  
  init() {
    myInfo = myInfoSubject.asDriver(onErrorDriveWith: .empty())
  }
  
  func fetchMyInfoData() {
    AccountService.shared.inquireMyInfo()
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          print(model)
          guard let data = model.data else { return }
          owner.myInfoSubject.onNext(data)
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  func fetchMyPlubbing(status: PlubbingStatusType) {
    MyPageService.shared.inquireMyMeeting(
      status: status,
      cursorID: 0
    )
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          print(model)
          guard let data = model.data else { return }
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
}
