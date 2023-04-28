//
//  IntroduceCategoryViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/23.
//

import RxSwift
import RxCocoa

protocol DetailRecruitmentViewModelType {
  // Input
  var selectPlubbingID: AnyObserver<Int> { get }
  var selectCancelApplication: AnyObserver<Void> { get }
  var selectEndRecruitment: AnyObserver<Void> { get }
  
  // Output
  var introduceCategoryTitleViewModel: Driver<IntroduceCategoryTitleViewModel> { get }
  var introduceCategoryInfoViewModel: Driver<IntroduceCategoryInfoViewModel> { get }
  var participantListViewModel: Driver<[AccountInfo]> { get }
  var meetingIntroduceModel: Driver<MeetingIntroduceModel> { get }
  var categories: Driver<[String]> { get }
  var isApplied: Driver<Bool> { get }
  var successCancelApplication: Signal<Void> { get }
  var isHost: Signal<Bool> { get }
}

// TODO: 이건준 -추후 API요청에 따른 result failure에 대한 에러 묶어서 처리하기
final class DetailRecruitmentViewModel: DetailRecruitmentViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let selectPlubbingID: AnyObserver<Int> // 세부정보를 보고싶은 모집글에 대한 ID
  let selectCancelApplication: AnyObserver<Void> // [지원취소] 눌렀을 때
  let selectEndRecruitment: AnyObserver<Void> // 호스트용 [모집 끝내기] 눌렀을 때
  
  // Output
  let introduceCategoryTitleViewModel: Driver<IntroduceCategoryTitleViewModel> // 모집글 세부정보를 표시하기위한 UI 모델
  let introduceCategoryInfoViewModel: Driver<IntroduceCategoryInfoViewModel> // 모집글 세부정보를 표시하기위한 UI 모델
  let participantListViewModel: Driver<[AccountInfo]> // 모집글 세부정보를 표시하기위한 UI 모델
  let meetingIntroduceModel: Driver<MeetingIntroduceModel> // 모집글 세부정보를 표시하기위한 UI 모델
  let categories: Driver<[String]>
  let isApplied: Driver<Bool> // 해당 모집글을 신청했는지
  let successCancelApplication: Signal<Void> // [지원취소] 성공했는지
  let isHost: Signal<Bool> // 해당 모집글이 호스트인지
  
  init() {
    let selectingPlubbingID = PublishSubject<Int>()
    let selectingCancelApplication = PublishSubject<Void>()
    let selectingEndRecruitment = PublishSubject<Void>()
    
    selectPlubbingID = selectingPlubbingID.asObserver()
    selectCancelApplication = selectingCancelApplication.asObserver()
    selectEndRecruitment = selectingEndRecruitment.asObserver()
    
    let fetchingDetail = selectingPlubbingID
      .flatMapLatest(RecruitmentService.shared.inquireDetailRecruitment(plubbingID:))
      .share()
    
    let successFetchingDetail = fetchingDetail.compactMap { result -> DetailRecruitmentResponse? in
      guard case .success(let detailRecruitmentResponse) = result else { return nil }
      return detailRecruitmentResponse.data
    }
    
    let requestCancelApplication = selectingCancelApplication
      .withLatestFrom(selectingPlubbingID)
      .flatMapLatest(RecruitmentService.shared.cancelApplication(plubbingID:))
    
    let requestEndRecruitment = selectingEndRecruitment
      .withLatestFrom(selectingPlubbingID)
      .flatMapLatest(RecruitmentService.shared.endRecruitment(plubbingID:))
    
    requestEndRecruitment
      .subscribe(onNext: { _ in
        print("[모집 끝내기] 성공했습니다")
      })
      .disposed(by: disposeBag)
    
    introduceCategoryTitleViewModel = successFetchingDetail.map { response -> IntroduceCategoryTitleViewModel in
      return IntroduceCategoryTitleViewModel(
        title: response.title,
        name: response.name,
        infoText: response.placeName
      )
    }
    .asDriver(onErrorDriveWith: .empty())
    
    isApplied = successFetchingDetail
      .map { $0.isApplied }
      .asDriver(onErrorDriveWith: .empty())
    
    introduceCategoryInfoViewModel = successFetchingDetail.map { response -> IntroduceCategoryInfoViewModel in
      return IntroduceCategoryInfoViewModel(
        recommendedText: response.goal,
        meetingImageURL: response.mainImage,
        meetingImage: nil,
        categoryInfoListModel: .init(
          placeName: response.placeName,
          peopleCount: response.remainAccountNum,
          dateTime: response.days.map(\.kor).joined(separator: ",")
        )
      )
    }
    .asDriver(onErrorDriveWith: .empty())
    
    isHost = successFetchingDetail.map { response -> Bool in
      return response.isHost
    }
    .asSignal(onErrorSignalWith: .empty())
    
    participantListViewModel = successFetchingDetail.map { response -> [AccountInfo] in
      return response.joinedAccounts
    }
    .asDriver(onErrorDriveWith: .empty())
    
    meetingIntroduceModel = successFetchingDetail.map { response -> MeetingIntroduceModel in
      return MeetingIntroduceModel(
        title: response.title,
        introduce: response.introduce
      )
    }
    .asDriver(onErrorDriveWith: .empty())
    
    categories = successFetchingDetail.map { response -> [String] in
      return response.categories
    }
    .asDriver(onErrorDriveWith: .empty())
    
    successCancelApplication = requestCancelApplication
      .compactMap { result -> Void? in
        guard case .success(_) = result else { return nil }
        return ()
      }
      .asSignal(onErrorSignalWith: .empty())
  }
}
