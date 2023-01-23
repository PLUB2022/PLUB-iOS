//
//  InterestListViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import RxSwift
import RxCocoa

protocol SelectedCategoryViewModelType {
  // Input
  var selectCategoryId: AnyObserver<String> { get }
  
  // Output
  
  func createSelectedCategoryChartCollectionViewCellModels() -> Observable<[SelectedCategoryCollectionViewCellModel]>
}

class SelectedCategoryViewModel: SelectedCategoryViewModelType {
  
  // Input
  let selectCategoryId: AnyObserver<String>
  
  // Output
  
  
  init() {
    let selectingCategoryId = PublishSubject<String>()
    self.selectCategoryId = selectingCategoryId.asObserver()
    
    let fetchingSelectedCategory = selectingCategoryId
      .flatMapLatest(MeetingService.shared.inquireCategoryMeeting(categoryId: ))
      .share()
    
    let successFetching = fetchingSelectedCategory.map { result -> CategoryMeetingResponse? in
      guard case .success(let response) = result else { return nil }
      return response.data
    }
    
    let fetchingCellData = successFetching.map { response in
//      return SelectedCategoryCollectionViewCellModel(title: <#T##String#>, description: <#T##String#>, selectedCategoryInfoViewModel: <#T##CategoryInfoListViewModel#>)
    }
  }
  
  private let selectedCategoryChartCollectionViewCellModels: [SelectedCategoryCollectionViewCellModel] = [
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoModel: .init(location: "서울 서초구", peopleCount: 10, when: "매주 금요일 | 오후 5시 30분")),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoModel: .init(location: "서울 서초구", peopleCount: 10, when: "매주 금요일 | 오후 5시 30분")),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoModel: .init(location: "서울 서초구", peopleCount: 10, when: "매주 금요일 | 오후 5시 30분")),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoModel: .init(location: "서울 서초구", peopleCount: 10, when: "매주 금요일 | 오후 5시 30분")),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoModel: .init(location: "서울 서초구", peopleCount: 10, when: "매주 금요일 | 오후 5시 30분")),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoModel: .init(location: "서울 서초구", peopleCount: 10, when: "매주 금요일 | 오후 5시 30분")),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoModel: .init(location: "서울 서초구", peopleCount: 10, when: "매주 금요일 | 오후 5시 30분")),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoModel: .init(location: "서울 서초구", peopleCount: 10, when: "매주 금요일 | 오후 5시 30분")),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoModel: .init(location: "서울 서초구", peopleCount: 10, when: "매주 금요일 | 오후 5시 30분"))
  ]
  
  func createSelectedCategoryChartCollectionViewCellModels() -> Observable<[SelectedCategoryCollectionViewCellModel]> {
    return Observable.just(selectedCategoryChartCollectionViewCellModels)
  }
}
