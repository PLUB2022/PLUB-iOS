//
//  BaseService.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/13.
//

import Foundation

import Alamofire
import RxCocoa
import RxSwift
import Then

extension Session: Then { }

class BaseService {
  
  private let session = Session(configuration: .af.default, interceptor: Interceptor())
  
  /// Network Response에 대해 값을 검증하고 그 결과값을 리턴합니다.
  /// - Parameters:
  ///   - statusCode: http 상태 코드
  ///   - data: 응답값으로 받아온 `Data`
  ///   - type: Data 내부를 구성하는 타입
  /// - Returns: GeneralResponse 또는 Plub Error
  ///
  /// 해당 메서드는 검증을 위해 사용됩니다.
  /// 요청값을 전달하고 응답받은 값을 처리하고 싶은 경우 `requestObject(_:type:)`을 사용해주세요.
  @available(*, deprecated, renamed: "validateHTTPResponse(by:_:type:)")
  func evaluateStatus<T: Codable>(
    by statusCode: Int,
    _ data: Data,
    type: T.Type
  ) -> NetworkResult<GeneralResponse<T>> {
    guard let decodedData = try? JSONDecoder().decode(GeneralResponse<T>.self, from: data) else {
      return .pathError
    }
    switch statusCode {
    case 200..<300:
      return .success(decodedData)
    case 400..<500:
      return .requestError(decodedData)
    case 500:
      return .serverError
    default:
      return .networkError
    }
  }
  
  /// PLUB 서버에 필요한 값을 동봉하여 요청합니다.
  /// - Parameters:
  ///   - target: Router를 채택한 인스턴스(instance)
  ///   - type: 응답 값에 들어오는 `data`를 파싱할 모델
  @available(*, deprecated, renamed: "sendObservableRequest(_:)")
  func sendRequest<T: Codable>(
    _ router: Router,
    type: T.Type = EmptyModel.self
  ) -> Observable<NetworkResult<GeneralResponse<T>>> {
    Single.create { observer in
      self.session.request(router).responseData { response in
        switch response.result {
        case .success(let data):
          guard let statusCode = response.response?.statusCode else {
            fatalError("statusCode가 없는 응답값????")
          }
          // PLUBError와 Success(GeneralResponse<T>)가 같이 들어가 있음
          observer(.success(self.evaluateStatus(by: statusCode, data, type: type)))
        case .failure(let error):
          observer(.failure(error)) // Alamofire Error
        }
      }
      return Disposables.create()
    }
    .asObservable()
  }
  
  /// PLUB 서버에 필요한 값과 이미지 파일을 동봉하여 요청합니다.
  /// - MultipartFormData:
  ///   - 이미지 formData: byte buffer 형식
  func sendRequestWithImage<T: Codable>(
    _ formData: MultipartFormData,
    _ router: Router,
    type: T.Type = EmptyModel.self
  ) -> Observable<NetworkResult<GeneralResponse<T>>> {
    Single.create { observer in
      self.session.upload(multipartFormData: formData, with: router).responseData { response in
        switch response.result {
        case .success(let data):
          guard let statusCode = response.response?.statusCode else {
            fatalError("statusCode가 없는 응답값????")
          }
          // PLUBError와 Success(GeneralResponse<T>)가 같이 들어가 있음
          observer(.success(self.evaluateStatus(by: statusCode, data, type: type)))
        case .failure(let error):
          observer(.failure(error)) // Alamofire Error
        }
      }
      return Disposables.create()
    }
    .asObservable()
  }
  
  
  /// Network Response에 대해 검증한 결과값을 리턴합니다.
  /// - Parameters:
  ///   - statusCode: http 상태 코드
  ///   - data: 응답값으로 받아온 `Data`
  ///   - type: Data 내부를 구성하는 타입
  /// - Returns: GeneralResponse 또는 Plub Error
  ///
  /// 해당 메서드는 검증을 위해 사용됩니다.
  /// 서버로부터 값을 받아오거나 받아오지 못했을 때, 성공한 값을 리턴 또는 그에 맞는 PLUB Error를 처리합니다.
  private func validateHTTPResponse<T: Codable>(
    by statusCode: Int,
    _ data: Data,
    type: T.Type
  ) -> Result<GeneralResponse<T>, PLUBError<GeneralResponse<T>>> {
    guard let decodedData = try? JSONDecoder().decode(GeneralResponse<T>.self, from: data) else {
      return .failure(.decodingError(raw: data))
    }
    switch statusCode {
    case 200..<300:
      // 로깅을 위해 json을 이쁘게 포맷팅
      guard let jsonData = try? JSONSerialization.jsonObject(with: data),
            let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted),
            let formattedString = String(data: prettyJsonData, encoding: .utf8)
      else {
        Log.fault("decodingError: \n\(data)", category: .network)
        return .failure(.decodingError(raw: data))
      }
      if decodedData.data != nil {
        Log.notice("Success: \n\(formattedString)"  , category: .network)
        return .success(decodedData)
      }
      Log.fault("decodingError: \n\(formattedString)", category: .network)
      return .failure(.decodingError(raw: data))
    case 400..<500:
      Log.error("Request Error: \n\(decodedData)", category: .network)
      return .failure(.requestError(decodedData))
    case 500..<600:
      return .failure(.serverError)
    default:
      return .failure(.unknownedError)
    }
  }
  
  /// PLUB 서버에 필요한 값을 동봉하여 요청합니다.
  /// - Parameters:
  ///   - target: Router를 채택한 인스턴스(instance)
  ///
  /// 해당 메서드로 파이프라인을 시작하게 되면, [weak self]를 통한 retain cycle를 고려하지 않아도 됩니다.
  /// 값을 파이프라인에 전달하게 되면 그 뒤 바로 종료되는 것을 보장하기 때문입니다.
  func sendObservableRequest<T: Codable>(_ router: Router) -> Observable<T> {
    Single.create { observer in
      
      self.session.request(router)
        .validate({ request, response, data in
          if response.statusCode != 401 {
            return .success(Void())
          }
          let reason = AFError.ResponseValidationFailureReason.unacceptableStatusCode(code: response.statusCode)
          return .failure(AFError.responseValidationFailed(reason: reason))
        })
        .responseData { response in
        switch response.result {
        case .success(let data):
          guard let statusCode = response.response?.statusCode
          else {
            observer(.failure(PLUBError<T>.unknownedError))
            return
          }
          
          switch self.validateHTTPResponse(by: statusCode, data, type: T.self) {
          case .success(let decodedData):
            // validateHTTPResponse에서 success인 경우 Data값을 보장함
            observer(.success(decodedData.data!))
            
          case .failure(let error):
            observer(.failure(error))
          }
          
        case .failure(let error):
          
          switch error {
          case .sessionTaskFailed(let urlError as URLError) where urlError.code == .notConnectedToInternet:
            // 네트워크 연결이 되어있지 않은 경우
            observer(.failure(PLUBError<T>.networkError))
            
          default:
            observer(.failure(PLUBError<T>.alamofireError(error))) // Alamofire Error
            
          }
        }
      }
      
      return Disposables.create()
    }
    .asObservable()
  }
}

// MARK: - Components

extension BaseService {
  /// 빈 모델입니다.
  struct EmptyModel: Codable { }
  
  typealias PLUBResult<T: Codable> = Observable<NetworkResult<GeneralResponse<T>>>
}
