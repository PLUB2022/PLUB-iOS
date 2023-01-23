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
  var updatedCellData: Driver<[SelectedCategoryCollectionViewCellModel]> { get }
  
  func createSelectedCategoryChartCollectionViewCellModels() -> Observable<[SelectedCategoryCollectionViewCellModel]>
}

class SelectedCategoryViewModel: SelectedCategoryViewModelType {
  
  private var disposeBag = DisposeBag()
  
  // Input
  let selectCategoryId: AnyObserver<String>
  
  // Output
  let updatedCellData: Driver<[SelectedCategoryCollectionViewCellModel]>
  
  init() {
    let selectingCategoryId = PublishSubject<String>()
    let updatingCellData = BehaviorSubject<[SelectedCategoryCollectionViewCellModel]>(value: [])
    self.selectCategoryId = selectingCategoryId.asObserver()
    self.updatedCellData = updatingCellData.asDriver(onErrorDriveWith: .empty())
    
    let fetchingSelectedCategory = selectingCategoryId.flatMapLatest { categoryId in
      return MeetingService.shared.inquireCategoryMeeting(categoryId: categoryId)
    }
    .share()

    let successFetching = fetchingSelectedCategory.map { result -> CategoryMeetingResponse? in
      guard case .success(let response) = result else { return nil }
      return response.data
    }
    
    let selectingContents = successFetching.map { response -> [Content]? in
      guard let response = response else { return nil }
      return response.content
    }
    
    selectingContents.subscribe(onNext: { contents in
      guard let contents = contents else { return }
      let model = contents.map { content in
        return SelectedCategoryCollectionViewCellModel(plubbingId: content.plubbingId, name: content.name, title: content.title, mainImage: content.mainImage, introduce: content.introduce, isBookmarked: content.isBookmarked, selectedCategoryInfoModel: .init(placeName: content.placeName, peopleCount: 5, when: "서울 서초구 | 월, 화, 수"))
      }
      updatingCellData.onNext(model)
    })
    .disposed(by: disposeBag)
  }
  
  private let selectedCategoryChartCollectionViewCellModels: [SelectedCategoryCollectionViewCellModel] = [
    .init(plubbingId: 1, name: "", title: "스트릿 댄스 신사동스 파이터", mainImage: nil, introduce: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", isBookmarked: false, selectedCategoryInfoModel: .init(placeName: "서울 서초구", peopleCount: 10, when: "매주 금요일 | 오후 5시 30분")),
    .init(plubbingId: 1, name: "", title: "스트릿 댄스 신사동스 파이터", mainImage: nil, introduce: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", isBookmarked: false, selectedCategoryInfoModel: .init(placeName: "서울 서초구", peopleCount: 10, when: "매주 금요일 | 오후 5시 30분")),
    .init(plubbingId: 1, name: "", title: "스트릿 댄스 신사동스 파이터", mainImage: nil, introduce: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", isBookmarked: false, selectedCategoryInfoModel: .init(placeName: "서울 서초구", peopleCount: 10, when: "매주 금요일 | 오후 5시 30분")),
    .init(plubbingId: 1, name: "", title: "스트릿 댄스 신사동스 파이터", mainImage: nil, introduce: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", isBookmarked: false, selectedCategoryInfoModel: .init(placeName: "서울 서초구", peopleCount: 10, when: "매주 금요일 | 오후 5시 30분")),
    .init(plubbingId: 1, name: "", title: "스트릿 댄스 신사동스 파이터", mainImage: nil, introduce: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", isBookmarked: false, selectedCategoryInfoModel: .init(placeName: "서울 서초구", peopleCount: 10, when: "매주 금요일 | 오후 5시 30분")),
    .init(plubbingId: 1, name: "", title: "스트릿 댄스 신사동스 파이터", mainImage: nil, introduce: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", isBookmarked: false, selectedCategoryInfoModel: .init(placeName: "서울 서초구", peopleCount: 10, when: "매주 금요일 | 오후 5시 30분"))
    
  ]
  
  func createSelectedCategoryChartCollectionViewCellModels() -> Observable<[SelectedCategoryCollectionViewCellModel]> {
    return Observable.just(selectedCategoryChartCollectionViewCellModels)
  }
}
