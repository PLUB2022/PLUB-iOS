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
  var selectPlubbingID: AnyObserver<String> { get }
  
  // Output
  var introduceCategoryTitleViewModel: Driver<IntroduceCategoryTitleViewModel> { get }
  var introduceCategoryInfoViewModel: Driver<IntroduceCategoryInfoViewModel> { get }
  var participantListViewModel: Driver<[AccountInfo]> { get }
  var meetingIntroduceModel: Driver<MeetingIntroduceModel> { get }
  var isApplied: Driver<Bool> { get }
}

// TODO: 이건준 -추후 API요청에 따른 result failure에 대한 에러 묶어서 처리하기
final class DetailRecruitmentViewModel: DetailRecruitmentViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let selectPlubbingID: AnyObserver<String> // 세부정보를 보고싶은 모집글에 대한 ID
  
  // Output
  let introduceCategoryTitleViewModel: Driver<IntroduceCategoryTitleViewModel> // 모집글 세부정보를 표시하기위한 UI 모델
  let introduceCategoryInfoViewModel: Driver<IntroduceCategoryInfoViewModel> // 모집글 세부정보를 표시하기위한 UI 모델
  let participantListViewModel: Driver<[AccountInfo]> // 모집글 세부정보를 표시하기위한 UI 모델
  let meetingIntroduceModel: Driver<MeetingIntroduceModel> // 모집글 세부정보를 표시하기위한 UI 모델
  let isApplied: Driver<Bool> // 해당 모집글을 신청했는지
  
  init() {
    let selectingPlubbingID = PublishSubject<String>()
    let successFetchingDetail = PublishRelay<DetailRecruitmentResponse>()
    self.selectPlubbingID = selectingPlubbingID.asObserver()
    
    let fetchingDetail = selectingPlubbingID
      .flatMapLatest(RecruitmentService.shared.inquireDetailRecruitment(plubbingID:))
      .share()
    
    fetchingDetail.compactMap { result -> DetailRecruitmentResponse? in
      guard case .success(let detailRecruitmentResponse) = result else { return nil }
      return detailRecruitmentResponse.data
    }
    .bind(to: successFetchingDetail)
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
        meetingImageURL: "",
        meetingImage: nil,
        categoryInfoListModel: .init(
          placeName: response.placeName,
          peopleCount: response.remainAccountNum,
          dateTime: "")
      )
    }
    .asDriver(onErrorDriveWith: .empty())
    
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
  }
}
