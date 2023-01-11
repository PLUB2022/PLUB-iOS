//
//  InterestListViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import RxSwift

protocol SelectedCategoryViewModelType {
  func createSelectedCategoryChartCollectionViewCellModels() -> Observable<[SelectedCategoryCollectionViewCellModel]>
}

class SelectedCategoryViewModel: SelectedCategoryViewModelType {
  
  private let selectedCategoryChartCollectionViewCellModels: [SelectedCategoryCollectionViewCellModel] = [
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoViewModel: CategoryInfoListViewModel(date: "토, 일", time: "오후 10시", peopleCount: 4)),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoViewModel: CategoryInfoListViewModel(date: "토, 일", time: "오후 10시", peopleCount: 4)),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoViewModel: CategoryInfoListViewModel(date: "토, 일", time: "오후 10시", peopleCount: 4)),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoViewModel: CategoryInfoListViewModel(date: "토, 일", time: "오후 10시", peopleCount: 4)),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoViewModel: CategoryInfoListViewModel(date: "토, 일", time: "오후 10시", peopleCount: 4)),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoViewModel: CategoryInfoListViewModel(date: "토, 일", time: "오후 10시", peopleCount: 4)),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoViewModel: CategoryInfoListViewModel(date: "토, 일", time: "오후 10시", peopleCount: 4)),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoViewModel: CategoryInfoListViewModel(date: "토, 일", time: "오후 10시", peopleCount: 4)),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoViewModel: CategoryInfoListViewModel(date: "토, 일", time: "오후 10시", peopleCount: 4)),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoViewModel: CategoryInfoListViewModel(date: "토, 일", time: "오후 10시", peopleCount: 4)),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoViewModel: CategoryInfoListViewModel(date: "토, 일", time: "오후 10시", peopleCount: 4)),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoViewModel: CategoryInfoListViewModel(date: "토, 일", time: "오후 10시", peopleCount: 4)),
    SelectedCategoryCollectionViewCellModel(title: "스트릿 댄스 신사동스 파이터", description: "스트릿 댄스를 배우고 싶은 신사동 여러분을 모집합니다.", selectedCategoryInfoViewModel: CategoryInfoListViewModel(date: "토, 일", time: "오후 10시", peopleCount: 4))
  ]
  
  func createSelectedCategoryChartCollectionViewCellModels() -> Observable<[SelectedCategoryCollectionViewCellModel]> {
    return Observable.just(selectedCategoryChartCollectionViewCellModels)
  }
}
