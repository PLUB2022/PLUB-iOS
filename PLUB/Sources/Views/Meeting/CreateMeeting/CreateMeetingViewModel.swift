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
  
  /// 주소
  private var addressRelay = BehaviorRelay<String?>(value: nil)
  
  /// 도로명 주소
  private var roadAddressRelay = BehaviorRelay<String?>(value: nil)
  
  /// 장소 이름
  private var placeNameRelay = BehaviorRelay<String?>(value: nil)
  
  /// x 좌표
  private var positionXRelay = BehaviorRelay<Double?>(value: nil)
  
  /// y 좌표
  private var positionYRelay = BehaviorRelay<Double?>(value: nil)
  
  /// 인원 수
  private var peopleNumberRelay = BehaviorRelay<Int>(value: 4)
  
  /// 질문 여부
  private var questionOnOffRelay = BehaviorRelay<Bool>(value: true)
  
  /// 질문 리스트
  private var questionsRelay = BehaviorRelay<[String]>(value: [])
  
  init() {
    categoryViewModel.selectedSubCategories
      .do { print($0) }
      .asObservable()
      .bind(to: categoryIDsRelay)
      .disposed(by: disposeBag)
    
    nameViewModel.introduceTitleInputRelay
      .do { print($0) }
      .asObservable()
      .bind(to: titleRelay)
      .disposed(by: disposeBag)
    
    nameViewModel.nameTitleInputRelay
      .do { print($0) }
      .asObservable()
      .bind(to: nameRelay)
      .disposed(by: disposeBag)
    
    introduceViewModel.goalInputRelay
      .do { print($0) }
      .asObservable()
      .bind(to: goalRelay)
      .disposed(by: disposeBag)
    
    introduceViewModel.introduceInputRelay
      .do { print($0) }
      .asObservable()
      .bind(to: introduceRelay)
      .disposed(by: disposeBag)
    
    dateViewModel.dateInputRelay
      .do { print($0) }
      .asObservable()
      .bind(to: daysRelay)
      .disposed(by: disposeBag)
    
    dateViewModel.timeInputRelay
      .do { print($0) }
      .asObservable()
      .bind(to: timeRelay)
      .disposed(by: disposeBag)
    
    dateViewModel.onOffInputRelay
      .do { print($0) }
      .asObservable()
      .bind(to: onOffRelay)
      .disposed(by: disposeBag)
    
    dateViewModel.locationInputRelay
      .do { print($0) }
      .asObservable()
      .bind(to: placeNameRelay)
      .disposed(by: disposeBag)
    
    peopleNumberViewModel.peopleNumber
      .do { print($0) }
      .asObservable()
      .bind(to: peopleNumberRelay)
      .disposed(by: disposeBag)
    
    questionViewModel.noQuestionMode
      .asObservable()
      .map { !$0 }
      .do { print($0) }
      .bind(to: questionOnOffRelay)
      .disposed(by: disposeBag)
    
    questionViewModel.questionListBehaviorRelay
      .asObservable()
      .map { $0.map { $0.question } }
      .do { print($0) }
      .bind(to: questionsRelay)
      .disposed(by: disposeBag)
  }
}
