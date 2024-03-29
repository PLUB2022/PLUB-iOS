//
//  MyPageViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/12.
//

import UIKit

import RxSwift
import RxCocoa

struct MyPageTableViewCellModel {
  var section: MyPlubbingResponse
  var isFolded: Bool
}

final class MyPageViewModel {
  private let disposeBag = DisposeBag()
  
  // Input
  let sectionTapped: AnyObserver<Int> // 섹션뷰 클릭 이벤트
  let updateMyInfo: AnyObserver<MyInfoResponse> // 내 정보 데이터 갱신
  
  // Output
  let myInfo: Driver<MyInfoResponse> // 내 정보 데이터
  let reloadData: Driver<Void> // 테이블 뷰 갱신
  let reloadSection: Driver<Int> // 테이블 뷰 섹션 갱신
  
  private let sectionTappedSubject = PublishSubject<Int>()
  private let updateMyInfoSubject = PublishSubject<MyInfoResponse>()
  private let myInfoSubject = PublishSubject<MyInfoResponse>()
  private let reloadDataSubject = PublishSubject<Void>()
  private let reloadSectionSubject = PublishSubject<Int>()
  
  // Data
  private(set) var myPlubbing: [MyPageTableViewCellModel] = [] // 나의 플러빙 데이터
  private(set) var myInfoData: MyInfoResponse? // 내정보
  
  init() {
    sectionTapped = sectionTappedSubject.asObserver()
    updateMyInfo = updateMyInfoSubject.asObserver()
    
    myInfo = myInfoSubject.asDriver(onErrorDriveWith: .empty())
    reloadData = reloadDataSubject.asDriver(onErrorDriveWith: .empty())
    reloadSection = reloadSectionSubject.asDriver(onErrorDriveWith: .empty())
    
    sectionTappedSubject
      .withUnretained(self)
      .subscribe(onNext: { owner, index in
        owner.myPlubbing[index].isFolded.toggle()
        owner.reloadSectionSubject.onNext(index)
      })
      .disposed(by: disposeBag)
    
    updateMyInfoSubject
      .withUnretained(self)
      .subscribe(onNext: { owner, myInfo in
        owner.setupMyInfoData(myInfo: myInfo)
      })
      .disposed(by: disposeBag)
  }
  
  func fetchMyInfoData() {
    AccountService.shared.inquireMyInfo()
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          print(model)
          guard let data = model.data else { return }
          owner.setupMyInfoData(myInfo: data)
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  func fetchMyPubbings() {
    let plubbingStatusTypes = PlubbingStatusType.allCases.map {
      return MyPageService.shared.inquireMyMeeting(
        status: $0,
        cursorID: 0
      )
    }
    
    // 플러빙 타입 4가지 API 동시 호출
    let successMyPubbings = Observable.zip(plubbingStatusTypes)
      .map {
        $0.compactMap { result -> MyPlubbingResponse? in
          guard case .success(let model) = result else { return nil }
          return model.data
        }
      }

    successMyPubbings
      .withUnretained(self)
      .subscribe(onNext: { owner, responses in
        for response in responses {
          guard !response.plubbings.isEmpty else { break }
          // 플러빙이 비어있지 않을 때만 섹션 추가
          owner.myPlubbing.append(
            .init(section: response, isFolded: true)
          )
        }
        
        // 테이블 뷰 리로드
        owner.reloadDataSubject.onNext(())
      }, onError: { error in
          print("")
      })
      .disposed(by: disposeBag)
  }
  
  func removeCell(with plubbingID: Int) {
    myPlubbing.enumerated().forEach { (i, data) in
      data.section.plubbings.enumerated().forEach { (j, plubbing) in
        if (plubbing.plubbingID == plubbingID) {
          myPlubbing[i].section.plubbings.remove(at: j)
          if myPlubbing[i].section.plubbings.count == 0 {
            myPlubbing.remove(at: i)
          }
          reloadDataSubject.onNext(())
          return
        }
      }
    }
  }
  
  private func setupMyInfoData(myInfo: MyInfoResponse) {
    myInfoData = myInfo
    myInfoSubject.onNext(myInfo)
  }
}
