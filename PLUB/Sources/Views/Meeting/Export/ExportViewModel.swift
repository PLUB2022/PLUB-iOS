//
//  ExportViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/23.
//

import RxSwift
import RxCocoa

final class ExportViewModel {
  private let disposeBag = DisposeBag()
  private let plubbingID: Int
  
  // Output
  let accountList: Driver<[AccountInfo]>
  let successExport: Driver<String>
  
  private let accountListRelay = BehaviorRelay<[AccountInfo]>.init(value: Array.init())
  private let successExportSubject = PublishSubject<String>()
  
  init(plubbingID: Int) {
    self.plubbingID = plubbingID
    accountList = accountListRelay.asDriver()
    successExport = successExportSubject.asDriver(onErrorDriveWith: .empty())
    
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
  
  func exportMember(indexPathRow: Int) {
    let account = accountListRelay.value[indexPathRow]
    let accountID = account.accountId
    MeetingService.shared.exportMeetingMember(plubbingID: plubbingID, accountID: accountID)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        let oldValue = owner.accountListRelay.value
          .filter { $0.accountId != accountID }
        
        owner.accountListRelay.accept(oldValue)
        
        if oldValue.isEmpty {
          //TODO: - 수빈 noneView 화면으로 전환
        }
        
        owner.successExportSubject.onNext(account.nickname)
      })
      .disposed(by: disposeBag)
  }
}
