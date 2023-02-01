//
//  OnboardingViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/31.
//

import RxCocoa
import RxSwift

protocol OnboardingViewModelType: OnboardingViewModel {
  // Input
  var nextButtonTapped: AnyObserver<Void> { get }
  
  // Output
  var emitTitles: Driver<String> { get }
  var emitDescriptions: Driver<String> { get }
  var emitLottieJSONName: Driver<String> { get }
  var emitCurrentPage: Driver<Int> { get }
  var shouldMoveLoginVC: Driver<Bool> { get }
}

final class OnboardingViewModel: OnboardingViewModelType {
  
  // Input
  let nextButtonTapped: AnyObserver<Void>
  
  // Output
  let emitTitles: Driver<String>        // titles에 들어있는 특정 `title`을 구독
  let emitDescriptions: Driver<String>  // Descriptions에 들어있는 특정 `description`을 구독
  let emitLottieJSONName: Driver<String>// Lottie 애니메이션인 json파일의 이름을 구독
  let emitCurrentPage: Driver<Int>      // 현재 보여져야할 pagecontrol의 currentpage를 구독
  let shouldMoveLoginVC: Driver<Bool>   // 로그인 VC를 보여줘야할지 말지에 대한 부울연산값을 구독
  
  private let titles = ["취향을 함께", "성장을 함께", "친구와 함께"]
  private let descriptions = [
    "좋아하는 것들을\n함께 나눌 사람들을 찾아보아요",
    "같은 목표를 가진 사람들과 꾸준하고\n깊이 있는 소통을 하며 발전할 수 있어요",
    "주변 친구들과 모임을 만들어\n편하게 관리하고 즐거운 추억을 쌓을 수 있어요"
  ]
  
  private let lottieJSONNames = ["Onboarding1", "Onboarding2", "Onboarding3"]
  
  /// 제공되는 title과 subtitle의 개수
  var count: Int {
    titles.count
  }
  
  /// 배열의 index를 관리하는 Relay
  private let indexRelay = BehaviorRelay(value: 0)
  
  /// 버튼이 탭되었을 때를 관장하는 Subject
  private let buttonTappedSubject = PublishSubject<Void>()
  
  /// ViewModel의 title을 emit해주는 Subject
  private let titlesSubject = PublishSubject<String>()
  
  /// ViewModel의 description을 emit해주는 Subject
  private let descriptionsSubject = PublishSubject<String>()
  
  /// ViewModel의 `lottieJSONNames`를 emit해주는 Subject
  private let lottieAnimationsNameSubject = BehaviorSubject<String>(value: "Onboarding1")
  
  /// PageControl의 currentPage를 위한 Subject, index에 맞게 emit하기 위해 사용됩니다.
  private let currentPageSubject = PublishSubject<Int>()
  
  /// LoginViewController가 보여져야하는지를 처리하는 Subject
  private let shouldMoveLoginVCSubject = PublishSubject<Bool>()
  
  private let disposeBag = DisposeBag()
  
  init() {
    // Input
    nextButtonTapped = buttonTappedSubject.asObserver()
    
    // Output
    emitTitles = titlesSubject.asDriver(onErrorJustReturn: titles[0])
    emitDescriptions = descriptionsSubject.asDriver(onErrorJustReturn: descriptions[0])
    emitLottieJSONName = lottieAnimationsNameSubject.asDriver(onErrorJustReturn: lottieJSONNames[0])
    shouldMoveLoginVC = shouldMoveLoginVCSubject.asDriver(onErrorJustReturn: false)
    emitCurrentPage = currentPageSubject.asDriver(onErrorJustReturn: 0)
    
    bind()
  }
  
  private func bind() {
    // 버튼이 탭되었을 시 index를 1 증가 시킴
    buttonTappedSubject
      .map { [weak self] in (self?.indexRelay.value ?? -1) + 1 }
      .bind(to: indexRelay)
      .disposed(by: disposeBag)
    
    let indexDriver = indexRelay.asDriver()
      .filter { [weak self] in $0 < self?.titles.count ?? 0 } // self를 가져오는 데 실패했다면 무조건 false
    
    // index가 emit되면 title도 배열의 값을 가져와 emit
    indexDriver
      .map { [weak self] in self?.titles[$0] ?? "" }
      .drive(titlesSubject)
      .disposed(by: disposeBag)
    
    // description도 배열의 값을 가져와 emit
    indexDriver
      .map { [weak self] in self?.descriptions[$0] ?? "" }
      .drive(descriptionsSubject)
      .disposed(by: disposeBag)
    
    // lottie animation 이름 emit
    indexDriver
      .map { [weak self] in self?.lottieJSONNames[$0] ?? "" }
      .drive(lottieAnimationsNameSubject)
      .disposed(by: disposeBag)
    
    // currentPage에 따른 인덱스 제공
    indexDriver
      .drive(currentPageSubject)
      .disposed(by: disposeBag)
    
    indexRelay.map { [weak self] index in
      guard let self else { return false }
      return index == self.titles.count
    }
    .bind(to: shouldMoveLoginVCSubject)
    .disposed(by: disposeBag)
  }
}
