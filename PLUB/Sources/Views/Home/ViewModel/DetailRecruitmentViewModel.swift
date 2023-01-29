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
  
  // Output
  var introduceCategoryTitleViewModel: Driver<IntroduceCategoryTitleViewModel> { get }
  var introduceCategoryInfoViewModel: Driver<IntroduceCategoryInfoViewModel> { get }
  var participantListViewModel: Driver<[AccountInfo]> { get }
}

class DetailRecruitmentViewModel: DetailRecruitmentViewModelType {
  
  private var disposeBag = DisposeBag()
  
  // Input
  let selectPlubbingID: AnyObserver<Int>
  
  // Output
  let introduceCategoryTitleViewModel: Driver<IntroduceCategoryTitleViewModel>
  let introduceCategoryInfoViewModel: Driver<IntroduceCategoryInfoViewModel>
  let participantListViewModel: Driver<[AccountInfo]>
  
  init() {
    let selectingPlubbingID = PublishSubject<Int>()
    let fetchingDetailRecruitment = PublishSubject<DetailRecruitmentModel>()
    
    self.selectPlubbingID = selectingPlubbingID.asObserver()
//    self.fetchDetailRecruitment = fetchingDetailRecruitment.asDriver(onErrorDriveWith: .empty())
    
    let fetchingDetail = selectingPlubbingID
      .map { "\($0)" }
      .flatMapLatest(RecruitmentService.shared.inquireDetailRecruitment(plubbingID:))
      .share()
    
    fetchingDetail.subscribe(onNext: { result in
      print("안돼요 = \(result)")
    })
    .disposed(by: disposeBag)
    
    let successFetchingDetail = fetchingDetail.map { result -> DetailRecruitmentResponse? in
      print("뭐냐고 = \(result)")
      guard case .success(let detailRecruitmentResponse) = result else { return nil }
      print("돼냐 = \(detailRecruitmentResponse.data)")
      return detailRecruitmentResponse.data
    }
    
    introduceCategoryTitleViewModel = successFetchingDetail.compactMap { response -> IntroduceCategoryTitleViewModel? in
      guard let response = response else { return nil }
      return IntroduceCategoryTitleViewModel(title: response.title, introduce: response.introduce, infoText: response.placeName)
    }
    .asDriver(onErrorDriveWith: .empty())
    
    introduceCategoryInfoViewModel = successFetchingDetail.compactMap { response -> IntroduceCategoryInfoViewModel? in
      guard let response = response else { return nil }
      return IntroduceCategoryInfoViewModel(recommendedText: response.goal, meetingImage: response.mainImage ?? "", categortInfoListModel: .init(placeName: response.placeName, peopleCount: response.remainAccountNum, when: ""))
    }
    .asDriver(onErrorDriveWith: .empty())
    
    participantListViewModel = successFetchingDetail.compactMap { response -> [AccountInfo]? in
      guard let response = response else { return nil }
      return response.joinedAccounts
    }
    .asDriver(onErrorDriveWith: .empty())
  }
}
