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
  
  // MARK: - Protocol Properties
  
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
  
  // MARK: - Custom Properties
  
  private let _titles = [
    "가입을 위한 약관 동의가 필요해요.",
    "먼저, 성별과 태어난 날을 알려주세요.",
    "프로필을 만들어 볼까요?",
    "님을 조금 더 알고싶어요!",
    "마지막으로, 관심 있는 분야를 모두 선택해주세요."
  ]
  
  private let _subtitles = [
    "서비스를 이용할 때 필요해요.",
    "서비스의 원활한 이용을 위해 정확한 정보를 입력해주세요!",
    "멋진 사진을 등록하고 나만의 닉네임을 만들어 주세요! 닉네임 변경은 1회 가능해요!",
    "취미, 관심사, 가치관, 종사하는 분야, 뭐든 좋아요.",
    "님이 흥미로워 할 만한 모임을 추천해 드릴게요."
  ]
  
  var titles: [NSAttributedString] {
    _titles.map {
      let defaultString = NSAttributedString(string: $0)
      // 닉네임을 넣어야하는 구간이 아닌 경우
      if _titles[3] != $0 {
        return defaultString
      }
      
      // 닉네임 설정이 안된 경우 (발생 가능성 0%)
      guard let nickname = try? userNicknameSubject.value() else {
        return defaultString
      }
      // 닉네임만 색상을 main컬러로 적용
      let mutableString = NSMutableAttributedString(string: nickname, attributes: [.foregroundColor: UIColor.main])
      mutableString.append(defaultString)
      return mutableString
    }
  }
  
  var subtitles: [NSAttributedString] {
    _subtitles.map {
      let defaultString = NSAttributedString(string: $0)
      // 닉네임을 넣어야하는 구간이 아닌 경우
      if _subtitles[4] != $0 {
        return defaultString
      }
      // 닉네임 설정이 안된 경우 (발생 가능성 0%)
      guard let nickname = try? userNicknameSubject.value() else {
        return defaultString
      }
      return NSAttributedString(string: nickname + $0)
    }
  }
  
  private var stateList = [Bool]()
  
  // MARK: - Subjects
  
  private let userCategoriesSubject = PublishSubject<[Int]>()             // 유저 카테고리 서브젝트
  private let userProfileSubject = BehaviorSubject<UIImage?>(value: nil)  // 유저 프로필 서브젝트
  private let userBirthSubject = PublishSubject<Date>()                   // 유저 생일 서브젝트
  private let userSexSubject = PublishSubject<Sex>()                      // 유저 성별 서브젝트
  private let userIntroductionSubject = PublishSubject<String>()          // 유저 소개글 서브젝트
  private let userNicknameSubject = BehaviorSubject<String>(value: "")    // 유저 닉네임 서브젝트
  private let userPoliciesSubject = PublishSubject<[Bool]>()              // 유저 약관 서브젝트
  
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
      .bind(to: buttonEnabledSubject)
      .disposed(by: disposeBag)
    
    userCategoriesSubject
      .withUnretained(self)
      .compactMap { owner, categories in
        owner.signUpRelay.value.with {
          $0.categoryList = categories
        }
      }
      .bind(to: signUpRelay)
      .disposed(by: disposeBag)
    
    userBirthSubject
      .withUnretained(self)
      .compactMap { owner, birthday in
        owner.signUpRelay.value.with {
          let formatter = DateFormatter().then {
            $0.dateFormat = "yyyy-MM-dd"
          }
          $0.birthday = formatter.string(from: birthday)
        }
      }
      .bind(to: signUpRelay)
      .disposed(by: disposeBag)
    
    userSexSubject
      .withUnretained(self)
      .compactMap { owner, sex in
        owner.signUpRelay.value.with {
          $0.sex = sex
        }
      }
      .bind(to: signUpRelay)
      .disposed(by: disposeBag)
    
    userIntroductionSubject
      .withUnretained(self)
      .compactMap { owner, introduction in
        owner.signUpRelay.value.with {
          $0.introduction = introduction
        }
      }
      .bind(to: signUpRelay)
      .disposed(by: disposeBag)
    
    userNicknameSubject
      .withUnretained(self)
      .compactMap { owner, nickname in
        owner.signUpRelay.value.with {
          $0.nickname = nickname
        }
      }
      .bind(to: signUpRelay)
      .disposed(by: disposeBag)
    
    userPoliciesSubject
      .withUnretained(self)
      .compactMap { owner, policies in
        owner.signUpRelay.value.with {
          $0.termsOfService = policies[0]
          $0.locationBasedService = policies[1]
          $0.termsAndConditionsForAges = policies[2]
          $0.privacyPolicy = policies[3]
          $0.marketing = policies[4]
        }
      }
      .bind(to: signUpRelay)
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
  
  func signUp() -> Observable<Bool> {
    // 1. 지금까지 초기화된 request model 등록
    var requestObservable = Observable<SignUpRequest>.just(signUpRelay.value)
    
    // 2. 이미지가 등록되어있는지 판단
    if let profileImage = try? userProfileSubject.value() {
      // 2-1. 이미지를 request model에 등록한 Observable로 세팅
      requestObservable = ImageService.shared.uploadImage(images: [profileImage], params: UploadImageRequest(type: .profile))
        .flatMap { response -> Observable<String?> in
          switch response {
          case let .success(imageModel):
            return .just(imageModel.data?.files.first?.fileUrl)
          default:
            // 이미지 등록이 되지 못함 (오류 발생)
            return .empty()
          }
        }
        .compactMap { $0 }
        .withUnretained(self)
        .map { owner, link in
          owner.signUpRelay.value.with {
            $0.profileImageLink = link
          }
        }
    }
    
    // 3. Sign Up 실행
    return requestObservable
      .debug("SignUp")
      .flatMap { AuthService.shared.signUpToPLUB(request: $0) }
      .compactMap { result in
        print(result)
        switch result {
        case let .success(response):
          guard let accessToken = response.data?.accessToken,
                let refreshToken = response.data?.refreshToken else {
            fatalError("성공했는데 Token값이 들어있지 않습니다. 이 경우는 발생할 수 없습니다.")
          }
          UserManager.shared.updatePLUBToken(accessToken: accessToken, refreshToken: refreshToken)
          return true // 토큰 저장 성공
        default:
          return false // 회원가입 실패
        }
      }
  }
}

// MARK: - Constants

extension SignUpViewModel {
  private enum Constants {
    static let defaultProfileName = "userDefaultImage"
  }
}
