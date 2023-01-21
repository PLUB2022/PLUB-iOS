//
//  KakaoLocationService.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/20.
//

import Foundation

import Alamofire
import RxCocoa
import RxSwift

class KakaoLocationService {
  static let shared = KakaoLocationService()
}

extension KakaoLocationService {
  func searchPlace(
    query: KakaoLocationRequest
  ) -> Observable<KakaoLocationResponse> {
    return sendRequest(
      KakaoLocationRouter.searchPlace(query)
    )
  }
  
  func sendRequest(
    _ router: Router
  ) -> Observable<KakaoLocationResponse> {
    Single.create { observer in
      AF.request(router).responseDecodable(of: KakaoLocationResponse.self) { response in
        switch response.result {
        case .success(let data):
          observer(.success(data))
        case .failure(let error):
          observer(.failure(error))
        }
      }
      return Disposables.create()
    }
    .asObservable()
  }
}
