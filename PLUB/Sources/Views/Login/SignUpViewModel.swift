//
//  SignUpViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/19.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

struct ValidationState {
  let index: Int  // 인덱스
  let state: Bool // 활성화 상태
}

protocol SignUpViewModelType: SignUpViewModel {
  // Input
  var validationState: AnyObserver<ValidationState> { get }
  var categories: AnyObserver<[Int]> { get }
  var profileImage: AnyObserver<UIImage?> { get }
  var birth: AnyObserver<Date> { get }
  var sex: AnyObserver<Sex> { get }
  var introduction: AnyObserver<String> { get }
  var nickname: AnyObserver<String> { get }
  var policies: AnyObserver<[Bool]> { get }
  
  // Output
  var isButtonEnabled: Driver<Bool> { get }
}

final class SignUpViewModel: SignUpViewModelType {
  
  // Input
  let validationState: AnyObserver<ValidationState> // 자식들에게서 상태값을 받음
  let categories: AnyObserver<[Int]>                // 유저가 선택한 카테고리
  let profileImage: AnyObserver<UIImage?>           // 유저로부터 받은 프로필 이미지
  let birth: AnyObserver<Date>                      // 유저의 생일
  let sex: AnyObserver<Sex>                         // 유저의 성별
  let introduction: AnyObserver<String>             // 유저의 소개글
  let nickname: AnyObserver<String>                 // 유저의 닉네임
  let policies: AnyObserver<[Bool]>                 // 유저가 체크한 약관 내역
  
  // Output
  let isButtonEnabled: Driver<Bool> // 버튼 활성화 제어
  
  private let disposeBag = DisposeBag()
  
  let titles = [
    "가입을 위한 약관 동의가 필요해요.",
    "먼저, 성별과 태어난 날을 알려주세요.",
    "프로필을 만들어 볼까요?",
    "님을 조금 더 알고싶어요!",
    "마지막으로, 관심 있는 분야를 모두 선택해주세요."
  ]
  
  let subtitles = [
    "서비스를 이용할 때 필요해요.",
    "서비스의 원활한 이용을 위해 정확한 정보를 입력해주세요!",
    "멋진 사진을 등록하고 나만의 닉네임을 만들어 주세요! 닉네임 변경은 1회 가능해요!",
    "취미, 관심사, 가치관, 종사하는 분야, 뭐든 좋아요.",
    "님이 흥미로워 할 만한 모임을 추천해 드릴게요."
  ]
  
  private var stateList = [Bool]()
  
  private let userCategoriesSubject = BehaviorSubject(value: [Int]())     // 유저 카테고리 서브젝트
  private let userProfileSubject = BehaviorSubject<UIImage?>(value: nil)  // 유저 프로필 서브젝트
  private let userBirthSubject = BehaviorSubject(value: Date())           // 유저 생일 서브젝트
  private let userSexSubject = BehaviorSubject(value: Sex.male)           // 유저 성별 서브젝트
  private let userIntroductionSubject = BehaviorSubject(value: "")        // 유저 소개글 서브젝트
  private let userNicknameSubject = BehaviorSubject(value: "")            // 유저 닉네임 서브젝트
  private let userPoliciesSubject = BehaviorSubject(value: [Bool]())      // 유저 약관 서브젝트
  
  private let signUpRelay = BehaviorRelay(value: SignUpRequest())         // 회원가입 플로우로 사용할 릴레이
  private let validationStateSubject = PublishSubject<ValidationState>()  // 버튼을 활성화할지 검증할 때 필요한 서브젝트
  private let buttonEnabledSubject = BehaviorSubject<Bool>(value: false)  // 버튼 활성화 여부 서브젝트
  
  // MARK: - Initialization
  
  init() {
    validationState = validationStateSubject.asObserver()
    categories = userCategoriesSubject.asObserver()
    profileImage = userProfileSubject.asObserver()
    birth = userBirthSubject.asObserver()
    sex = userSexSubject.asObserver()
    introduction = userIntroductionSubject.asObserver()
    nickname = userNicknameSubject.asObserver()
    policies = userPoliciesSubject.asObserver()
    
    isButtonEnabled = buttonEnabledSubject.asDriver(onErrorDriveWith: .empty())
    
    bind()
  }
  
  // MARK: - Custom Functions
  
  private func bind() {
    // 어떤 VC의 delegate로 인한 state 변경
    // ==> viewModel의 state 값 변경
    // ==> 값 변동 이후 버튼 활성화 유무 판단
    // ==> `버튼 활성화 Driver`에 부울값 emit
    validationStateSubject
      .withUnretained(self)
      .do { $0.changeState(index: $1.index, state: $1.state) }
      .map { owner, _ in
        owner.stateList.firstIndex(of: false) == nil
      }
      .bind(to: resultSubject)
      .disposed(by: disposeBag)
  }
  
  private func changeState(index: Int, state: Bool) {
    // 순서대로 오는 이상 index가 stateList의 개수보다 클 수 없음
    assert(stateList.count >= index)
    if stateList.count == index {
      stateList.append(state)
    }
    stateList[index] = state
  }
}

// MARK: - Constants

extension SignUpViewModel {
  private enum Constants {
    static let defaultProfileName = "userDefaultImage"
  }
}
