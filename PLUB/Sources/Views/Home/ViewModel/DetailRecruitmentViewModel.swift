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
}

final class DetailRecruitmentViewModel: DetailRecruitmentViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let selectPlubbingID: AnyObserver<String> // 세부정보를 보고싶은 모집글에 대한 ID
  
  // Output
  let introduceCategoryTitleViewModel: Driver<IntroduceCategoryTitleViewModel> // 모집글 세부정보를 표시하기위한 UI 모델
  let introduceCategoryInfoViewModel: Driver<IntroduceCategoryInfoViewModel> // 모집글 세부정보를 표시하기위한 UI 모델
  let participantListViewModel: Driver<[AccountInfo]> // 모집글 세부정보를 표시하기위한 UI 모델
  let meetingIntroduceModel: Driver<MeetingIntroduceModel> // 모집글 세부정보를 표시하기위한 UI 모델
  
  init() {
    let selectingPlubbingID = PublishSubject<String>()
    let successFetchingDetail = PublishSubject<DetailRecruitmentResponse>()
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
    
    self.introduceCategoryTitleViewModel = successFetchingDetail.map { response -> IntroduceCategoryTitleViewModel in
      return IntroduceCategoryTitleViewModel(title: response.title, name: response.name, infoText: response.placeName)
    }
    .asDriver(onErrorDriveWith: .empty())
    
    self.introduceCategoryInfoViewModel = successFetchingDetail.map { response -> IntroduceCategoryInfoViewModel in
      return IntroduceCategoryInfoViewModel(recommendedText: response.goal, meetingImageURL: "", meetingImage: nil, categoryInfoListModel: .init(placeName: response.placeName, peopleCount: response.remainAccountNum, dateTime: ""))
    }
    .asDriver(onErrorDriveWith: .empty())
    
    self.participantListViewModel = successFetchingDetail.map { response -> [AccountInfo] in
      return response.joinedAccounts
    }
    .asDriver(onErrorDriveWith: .empty())
    
    self.meetingIntroduceModel = successFetchingDetail.map { response -> MeetingIntroduceModel in
      return MeetingIntroduceModel(title: response.title, introduce: response.introduce)
    }
    .asDriver(onErrorDriveWith: .empty())
  }
}
