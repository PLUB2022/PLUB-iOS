//
//  CreateMeetingViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/31.
//

import UIKit

import RxSwift
import RxCocoa

final class CreateMeetingViewModel {
  private let disposeBag = DisposeBag()
  
  let categoryViewModel = MeetingCategoryViewModel()
  let nameViewModel = MeetingNameViewModel()
  let introduceViewModel = MeetingIntroduceViewModel()
  let dateViewModel = MeetingDateViewModel()
  let peopleNumberViewModel = MeetingPeopleNumberViewModel()
  let questionViewModel = MeetingQuestionViewModel()
  
  /// 선택한 카테고리 리스트
  private let categoryIDsRelay = BehaviorRelay<[Int]>(value: [])
  
  /// 플러빙 타이틀
  private var titleRelay = BehaviorRelay<String>(value: "")
  
  /// 플러빙 이름
  private var nameRelay = BehaviorRelay<String>(value: "")
  
  /// 플러빙 목표
  private var goalRelay = BehaviorRelay<String>(value: "")
  
  /// 소개
  private var introduceRelay = BehaviorRelay<String>(value: "")
  
  /// 메인 이미지
  private var mainImageRelay = BehaviorRelay<UIImage?>(value: nil)
  
  /// 시간
  private var timeRelay = BehaviorRelay<String>(value: "")
  
  /// 요일
  private var daysRelay = BehaviorRelay<[String]>(value: [])
  
  /// 온/오프라인
  private var onOffRelay = BehaviorRelay<OnOff>(value: .on)
  
  /// 장소
  private var locationRelay = BehaviorRelay<Location?>(value: nil)
  
  /// 인원 수
  private var peopleNumberRelay = BehaviorRelay<Int>(value: 4)
  
  /// 질문 여부
  private var questionOnOffRelay = BehaviorRelay<Bool>(value: true)
  
  /// 질문 리스트
  private var questionsRelay = BehaviorRelay<[String]>(value: [])
  
  init() {
    categoryViewModel.selectedSubCategories
      .asObservable()
      .bind(to: categoryIDsRelay)
      .disposed(by: disposeBag)
    
    nameViewModel.introduceTitleInputRelay
      .asObservable()
      .bind(to: titleRelay)
      .disposed(by: disposeBag)
    
    nameViewModel.nameTitleInputRelay
      .asObservable()
      .bind(to: nameRelay)
      .disposed(by: disposeBag)
    
    introduceViewModel.goalInputRelay
      .asObservable()
      .bind(to: goalRelay)
      .disposed(by: disposeBag)
    
    introduceViewModel.introduceInputRelay
      .asObservable()
      .bind(to: introduceRelay)
      .disposed(by: disposeBag)
    
    introduceViewModel.imageInputRelay
      .asObservable()
      .bind(to: mainImageRelay)
      .disposed(by: disposeBag)
    
    dateViewModel.dateInputRelay
      .asObservable()
      .bind(to: daysRelay)
      .disposed(by: disposeBag)
    
    dateViewModel.timeInputRelay
      .asObservable()
      .bind(to: timeRelay)
      .disposed(by: disposeBag)
    
    dateViewModel.onOffInputRelay
      .asObservable()
      .bind(to: onOffRelay)
      .disposed(by: disposeBag)
    
    dateViewModel.locationInputRelay
      .asObservable()
      .bind(to: locationRelay)
      .disposed(by: disposeBag)
    
    peopleNumberViewModel.peopleNumber
      .asObservable()
      .bind(to: peopleNumberRelay)
      .disposed(by: disposeBag)
    
    questionViewModel.noQuestionMode
      .asObservable()
      .map { !$0 }
      .bind(to: questionOnOffRelay)
      .disposed(by: disposeBag)
    
    questionViewModel.questionListBehaviorRelay
      .asObservable()
      .map { $0.map { $0.question } }
      .bind(to: questionsRelay)
      .disposed(by: disposeBag)
  }
  
  func setupMeetingData() -> CreateMeetingRequest {
    CreateMeetingRequest(
      categoryIDs: categoryIDsRelay.value,
      title: titleRelay.value,
      name: nameRelay.value,
      goal: goalRelay.value,
      introduce: introduceRelay.value,
      mainImage: nil,
      time: timeRelay.value,
      days: daysRelay.value,
      onOff: onOffRelay.value,
      address: locationRelay.value?.address,
      roadAddress: locationRelay.value?.roadAddress,
      placeName: locationRelay.value?.placeName,
      positionX: locationRelay.value?.positionX,
      positionY: locationRelay.value?.positionY,
      peopleNumber: peopleNumberRelay.value,
      questions: questionOnOffRelay.value ? questionsRelay.value : nil
    )
  }
}
