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
  var fetchDetailRecruitment: Driver<DetailRecruitmentModel> { get }
}

class DetailRecruitmentViewModel: DetailRecruitmentViewModelType {
  
  private var disposeBag = DisposeBag()
  
  // Input
  let selectPlubbingID: AnyObserver<Int>
  
  // Output
  let fetchDetailRecruitment: Driver<DetailRecruitmentModel>
  
  init() {
    let selectingPlubbingID = PublishSubject<Int>()
    let fetchingDetailRecruitment = PublishSubject<DetailRecruitmentModel>()
    
    self.selectPlubbingID = selectingPlubbingID.asObserver()
    self.fetchDetailRecruitment = fetchingDetailRecruitment.asDriver(onErrorDriveWith: .empty())
    
    let fetchingDetail = selectingPlubbingID
      .map { "\($0)" }
      .flatMapLatest(RecruitmentService.shared.inquireDetailRecruitment(plubbingId:))
      .share()
    
    let successFetchingDetail = fetchingDetail.map { result -> DetailRecruitmentResponse? in
      guard case .success(let detailRecruitmentResponse) = result else { return nil }
      return detailRecruitmentResponse.data
    }
    
    successFetchingDetail
      .subscribe(onNext: { response in
        guard let response = response else { return }
        let model = DetailRecruitmentModel(response: response)
        fetchingDetailRecruitment.onNext(model)
      })
      .disposed(by: disposeBag)
  }
}
