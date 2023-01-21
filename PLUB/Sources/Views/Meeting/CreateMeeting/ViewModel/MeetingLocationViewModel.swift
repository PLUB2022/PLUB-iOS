//
//  MeetingLocationViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/21.
//

import RxSwift
import RxCocoa

final class MeetingLocationViewModel {
  private lazy var disposeBag = DisposeBag()
  
  // Paging
  var pageCount = 1
  var isEndPage = false
  private var isLoading = false
  
  // Input
  let searchText = BehaviorRelay<String>.init(value: .init())
  let searchButtonTapped = PublishRelay<Void>()
  let fetchMoreData = PublishSubject<Void>()
  let selectedLocation = BehaviorRelay<KakaoLocationDocuments?>.init(value: nil)
  
  // Output
  let isEmptyList = PublishSubject<Bool>()
  let locationList = BehaviorRelay<[KakaoLocationDocuments?]>.init(value: Array.init())
  let totalCount = PublishSubject<Int>()
  let nextButtonEnabled = PublishRelay<Bool>()
  
  init() {
    fetchMoreData.subscribe { [weak self] _ in
      guard let self = self else { return }
      self.fetchLocationList(page: self.pageCount)
    }
    .disposed(by: disposeBag)
    
    selectedLocation.subscribe { [weak self] data in
      self?.nextButtonEnabled.accept(self?.selectedLocation.value == nil ? false : true)
    }
    .disposed(by: disposeBag)
  }
  
  func fetchLocationList(page: Int) {
    if isLoading || isEndPage { return }
    isLoading = true
    
    KakaoLocationService.shared.searchPlace(
      quary: KakaoLocationRequest(
        query: searchText.value,
        page: "\(page)"
      )
    )
    .subscribe(onNext: { [weak self] result in
      guard let self = self else { return }
      let documents = result.documents
      if documents.count == 0 {
        self.isEmptyList.onNext(true)
        self.selectedLocation.accept(nil)
      } else {
        self.totalCount.onNext(result.meta.totalCount)
        self.handleLocationData(data: documents)
        self.isEndPage = result.meta.isEnd
        self.isLoading = false
      }
    })
    .disposed(by: disposeBag)
  }
  
  func handleLocationData(data: [KakaoLocationDocuments]) {
    if pageCount == 1 {
      selectedLocation.accept(nil)
      isEmptyList.onNext(false)
      locationList.accept(data)
    } else {
      let oldData = locationList.value
      locationList.accept(oldData + data)
    }
    pageCount += 1
  }
}
