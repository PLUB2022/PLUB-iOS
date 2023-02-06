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
  private let categoryIDsRelay = BehaviorRelay<[SubCategory]>(value: [])
  
  /// 플러빙 타이틀
  private let titleRelay = BehaviorRelay<String>(value: "")
  
  /// 플러빙 이름
  private let nameRelay = BehaviorRelay<String>(value: "")
  
  /// 플러빙 목표
  private let goalRelay = BehaviorRelay<String>(value: "")
  
  /// 소개
  private let introduceRelay = BehaviorRelay<String>(value: "")
  
  /// 메인 이미지
  private let mainImageRelay = BehaviorRelay<UIImage?>(value: nil)
  
  /// 시간
  private let timeRelay = BehaviorRelay<Date?>(value: nil)
  
  /// 요일
  private let daysRelay = BehaviorRelay<[String]>(value: [])
  
  /// 온/오프라인
  private let onOffRelay = BehaviorRelay<OnOff>(value: .on)
  
  /// 장소
  private let locationRelay = BehaviorRelay<Location?>(value: nil)
  
  /// 인원 수
  private let peopleNumberRelay = BehaviorRelay<Int>(value: 4)
  
  /// 질문 여부
  private let questionOnOffRelay = BehaviorRelay<Bool>(value: true)
  
  /// 질문 리스트
  private let questionsRelay = BehaviorRelay<[String]>(value: [])
  
  init() {
    categoryViewModel.selectedSubCategories
      .asObservable()
      .bind(to: categoryIDsRelay)
      .disposed(by: disposeBag)
    
    nameViewModel.introduceTitleInputRelay
      .bind(to: titleRelay)
      .disposed(by: disposeBag)
    
    nameViewModel.nameTitleInputRelay
      .bind(to: nameRelay)
      .disposed(by: disposeBag)
    
    introduceViewModel.goalInputRelay
      .bind(to: goalRelay)
      .disposed(by: disposeBag)
    
    introduceViewModel.introduceInputRelay
      .bind(to: introduceRelay)
      .disposed(by: disposeBag)
    
    introduceViewModel.imageInputRelay
      .bind(to: mainImageRelay)
      .disposed(by: disposeBag)
    
    dateViewModel.dateInputRelay
      .bind(to: daysRelay)
      .disposed(by: disposeBag)
    
    dateViewModel.timeInputRelay
      .bind(to: timeRelay)
      .disposed(by: disposeBag)
    
    dateViewModel.onOffInputRelay
      .bind(to: onOffRelay)
      .disposed(by: disposeBag)
    
    dateViewModel.locationInputRelay
      .bind(to: locationRelay)
      .disposed(by: disposeBag)
    
    peopleNumberViewModel.peopleNumber
      .bind(to: peopleNumberRelay)
      .disposed(by: disposeBag)
    
    questionViewModel.noQuestionMode
      .map { !$0 }
      .bind(to: questionOnOffRelay)
      .disposed(by: disposeBag)
    
    questionViewModel.questionListBehaviorRelay
      .map { $0.map { $0.question } }
      .bind(to: questionsRelay)
      .disposed(by: disposeBag)
  }
  
  func setupMeetingData() -> CreateMeetingRequest {
    CreateMeetingRequest(
      categoryIDs: categoryIDsRelay.value.map { $0.id },
      title: titleRelay.value,
      name: nameRelay.value,
      goal: goalRelay.value,
      introduce: introduceRelay.value,
      mainImage: nil,
      time: dateString(timeRelay.value, format: "hhmm"),
      days: daysRelay.value,
      onOff: onOffRelay.value,
      address: locationRelay.value?.address,
      roadAddress: locationRelay.value?.roadAddress,
      placeName: locationRelay.value?.placeName,
      positionX: locationRelay.value?.positionX,
      positionY: locationRelay.value?.positionY,
      peopleNumber: peopleNumberRelay.value,
      questions: questionOnOffRelay.value ? questionsRelay.value : []
    )
  }
  
  func dateString(_ date: Date?, format: String) -> String {
    return DateFormatter().then {
      $0.dateFormat = format
      $0.locale = Locale(identifier: "ko_KR")
    }.string(from: date ?? Date())
  }
  
  func setupMeetingMainImage() -> UIImage? {
    return mainImageRelay.value
  }
  
  func setupCategoryNames() -> [String] {
    return categoryIDsRelay.value.map { $0.name }
  }
  
  func setupTime() -> String {
    return dateString(timeRelay.value, format: "a h시 m분")
  }
}
