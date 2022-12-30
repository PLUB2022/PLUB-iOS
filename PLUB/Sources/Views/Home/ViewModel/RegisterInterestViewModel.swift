//
//  RegisterInterestViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import Foundation
import RxSwift
import RxCocoa

protocol RegisterInterestViewModelType {
    // Input
    var selectDetailCell: AnyObserver<Void> { get }
    var deselectDetailCell: AnyObserver<Void> { get }
    
    // Output
    var registerInterestFetched: Driver<[RegisterInterestModel]> { get }
    var isEnabledFloatingButton: Driver<Bool> { get }
}

class RegisterInterestViewModel: RegisterInterestViewModelType {
    private var disposeBag = DisposeBag()
    private var registerInterestModels: [RegisterInterestModel] = [
        .init(interestCollectionType: .Art, interestDetailTypes: [
            .Art, .Computer, .Culture, .Employment, .Food, .Investment, .SportFitness, .LanguageStudy, .Employment, .SportFitness
        ]),
        .init(interestCollectionType: .SportFitness, interestDetailTypes: [
            .Art, .Computer, .Culture, .Employment, .Food, .Investment, .SportFitness, .LanguageStudy, .Employment, .SportFitness
        ]),
        .init(interestCollectionType: .Investment, interestDetailTypes: [
            .Art, .Computer, .Culture, .Employment, .Food, .Investment, .SportFitness, .LanguageStudy, .Employment, .SportFitness
        ]),
        .init(interestCollectionType: .LanguageStudy, interestDetailTypes: [
            .Art, .Computer, .Culture, .Employment, .Food, .Investment, .SportFitness, .LanguageStudy, .Employment, .SportFitness
        ]),
        .init(interestCollectionType: .Culture, interestDetailTypes: [
            .Art, .Computer, .Culture, .Employment, .Food, .Investment, .SportFitness, .LanguageStudy, .Employment, .SportFitness
        ]),
        .init(interestCollectionType: .Food, interestDetailTypes: [
            .Art, .Computer, .Culture, .Employment, .Food, .Investment, .SportFitness, .LanguageStudy, .Employment, .SportFitness
        ]),
        .init(interestCollectionType: .Employment, interestDetailTypes: [
            .Art, .Computer, .Culture, .Employment, .Food, .Investment, .SportFitness, .LanguageStudy, .Employment, .SportFitness
        ]),
        .init(interestCollectionType: .Computer, interestDetailTypes: [
            .Art, .Computer, .Culture, .Employment, .Food, .Investment, .SportFitness, .LanguageStudy, .Employment, .SportFitness
        ]),
    ]
    
    // Input
    var selectDetailCell: AnyObserver<Void>
    var deselectDetailCell: AnyObserver<Void>
    
    // Output
    var registerInterestFetched: Driver<[RegisterInterestModel]>
    var isEnabledFloatingButton: Driver<Bool> // 하나의 셀이라도 눌렸는지에 대한 값 방출
    
    init() {
        let registerInterestFetching = BehaviorSubject<[RegisterInterestModel]>(value: registerInterestModels)
        let selectingDetailCellCount = BehaviorSubject<Int>(value: 0)
        let selectingDetailCell = PublishSubject<Void>()
        let deselectingDetailCell = PublishSubject<Void>()
        self.registerInterestFetched = registerInterestFetching.asDriver(onErrorJustReturn: [])
        self.selectDetailCell = selectingDetailCell.asObserver()
        self.deselectDetailCell = deselectingDetailCell.asObserver()
        
        selectingDetailCell.withLatestFrom(selectingDetailCellCount)
            .map{ $0 + 1 }
            .subscribe(onNext: selectingDetailCellCount.onNext(_:))
            .disposed(by: disposeBag)
        
        deselectingDetailCell.withLatestFrom(selectingDetailCellCount)
            .map{ $0 - 1 }
            .subscribe(onNext: selectingDetailCellCount.onNext(_:))
            .disposed(by: disposeBag)
        
        isEnabledFloatingButton = selectingDetailCellCount.map{ $0 != 0 }.asDriver(onErrorJustReturn: false)
    }
}

