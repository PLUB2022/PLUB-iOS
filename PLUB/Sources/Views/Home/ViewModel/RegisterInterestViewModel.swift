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
    func createInterestSection() -> Observable<[RegisterInterestModel]> 
}

class RegisterInterestViewModel: RegisterInterestViewModelType {
    private var rgisterInterestModels: [RegisterInterestModel] = [
        .init(interestCollectionType: .Art),
        .init(interestCollectionType: .SportFitness),
        .init(interestCollectionType: .Investment),
        .init(interestCollectionType: .LanguageStudy),
        .init(interestCollectionType: .Culture),
        .init(interestCollectionType: .Food),
        .init(interestCollectionType: .Employment),
        .init(interestCollectionType: .Computer),
    ]
    
    public func createInterestSection() -> Observable<[RegisterInterestModel]> {
        return Observable.just(rgisterInterestModels)
    }
}
