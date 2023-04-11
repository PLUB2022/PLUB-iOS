//
//  WaitingViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/02.
//

import Foundation

import RxSwift
import RxCocoa

class WaitingViewModel {
  private let disposeBag = DisposeBag()
  private(set) var plubbingID: Int
  private(set) var myInfo: MyInfoResponse
  
  // Input
  let sectionTapped: AnyObserver<Int> // 섹션뷰 클릭 이벤트
  let cancelApplication: AnyObserver<Int> // 지원 취소
  let editApplication: AnyObserver<(sectionIndex: Int, accountID: Int)> // 지원서 수정
  
  // Output
  let meetingInfo: Driver<RecruitingModel> // 내 정보 데이터
  let reloadData: Driver<Void> // 테이블 뷰 갱신
  let reloadSection: Driver<Int> // 테이블 뷰 섹션 갱신
  let successCanelApplication: Driver<Void>
  
  private let sectionTappedSubject = PublishSubject<Int>()
  private let cancelApplicationSubject = PublishSubject<Int>()
  private let editApplicationSubject = PublishSubject<(sectionIndex: Int, accountID: Int)>()
  private let meetingInfoSubject = PublishSubject<RecruitingModel>()
  private let reloadDataSubject = PublishSubject<Void>()
  private let reloadSectionSubject = PublishSubject<Int>()
  private let successCanelApplicationSubject = PublishSubject<Void>()
  
  // Data
  private(set) var applications: [(data: Application, isFolded: Bool)] = []
  
  init(plubbingID: Int, myInfo: MyInfoResponse) {
    self.plubbingID = plubbingID
    self.myInfo = myInfo
    
    sectionTapped = sectionTappedSubject.asObserver()
    cancelApplication = cancelApplicationSubject.asObserver()
    editApplication = editApplicationSubject.asObserver()
    
    meetingInfo = meetingInfoSubject.asDriver(onErrorDriveWith: .empty())
    reloadData = reloadDataSubject.asDriver(onErrorDriveWith: .empty())
    reloadSection = reloadSectionSubject.asDriver(onErrorDriveWith: .empty())
    successCanelApplication = successCanelApplicationSubject.asDriver(onErrorDriveWith: .empty())
    
    fetchApplicants()
    
    sectionTappedSubject
      .withUnretained(self)
      .subscribe(onNext: { owner, index in
        owner.applications[index].isFolded.toggle()
        owner.reloadSectionSubject.onNext(index)
      })
      .disposed(by: disposeBag)
    
    cancelApplicationSubject
      .withUnretained(self)
      .subscribe(onNext: { owner, sectionIndex in
        owner.cancelApplication(
          sectionIndex: sectionIndex
        )
      })
      .disposed(by: disposeBag)
    
    editApplicationSubject
      .withUnretained(self)
      .subscribe(onNext: { owner, data in
//TODO: 수빈 - 질문 답변 수정 화면 연결
      })
      .disposed(by: disposeBag)
  }
  
  private func fetchApplicants() {
    RecruitmentService.shared.inquireMyApplication(plubbingID: plubbingID)
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          print(model)
          guard let data = model.data else { return }
          let plubbing = data.plubbingInfo
          owner.meetingInfoSubject.onNext(
            RecruitingModel(
              title: plubbing.name,
              schedule: owner.createScheduleString(
                days: plubbing.days,
                time: plubbing.time
              ),
              address: plubbing.address ?? "")
          )
          
          owner.applications.append(
            (
              Application(
                accountID: -1,
                userName: owner.myInfo.nickname,
                profileImage: owner.myInfo.profileImage,
                date: data.date,
                answers: data.answers),
              true
            )
          )
          // 테이블 뷰 리로드
          owner.reloadDataSubject.onNext(())
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func createScheduleString(days: [Day], time: String) -> String {
    let dateStr = days
      .map { $0.kor }
      .joined(separator: ", ")
    
    let date = DateFormatter().then {
      $0.dateFormat = "yyyy-MM-dd HH:mm:ss"
      $0.locale = Locale(identifier: "ko_KR")
    }.date(from: time) ?? Date()

    let timeStr = DateFormatter().then {
      $0.dateFormat = "a h시 m분"
      $0.locale = Locale(identifier: "ko_KR")
    }.string(from: date)
    
    return (dateStr.isEmpty ? "온라인" : dateStr)  + " | " + timeStr
  }
  
  private func cancelApplication(sectionIndex: Int) {
    RecruitmentService.shared.cancelApplication(
      plubbingID: plubbingID
    )
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          print(model)
          owner.applications.remove(at: sectionIndex)
          owner.successCanelApplicationSubject.onNext(())
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func editApplication(sectionIndex: Int, accountID: Int) {
    
  }
}
