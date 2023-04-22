//
//  ExportViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/23.
//

import RxSwift
import RxCocoa

final class ExportViewModel {
  //  exportMeetingMember

  private let disposeBag = DisposeBag()
  private let plubbingID: Int
  
  // Output
  let accountList: Driver<[AccountInfo]>
  
  private let accountListRelay = BehaviorRelay<[AccountInfo]>.init(value: Array.init())
  
  init(plubbingID: Int) {
    self.plubbingID = plubbingID
    accountList = accountListRelay.asDriver()
    
    fetchMeetingMember()
  }
  
  private func fetchMeetingMember() {
    MeetingService.shared.inquireMeetingMember(plubbingID: plubbingID)
      .withUnretained(self)
      .subscribe(onNext: { owner, model in
        owner.accountListRelay.accept(model.accounts)
      })
      .disposed(by: disposeBag)
  }
}
