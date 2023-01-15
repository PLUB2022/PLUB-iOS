//
//  BaseService.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/13.
//

import Foundation

import Alamofire
import Then

extension Session: Then { }

class BaseService {
  
  /// Alamofire의 Session instance입니다. 요청할 때 사용됩니다.
  let session = Session(configuration: .af.default.then {
    $0.timeoutIntervalForRequest = NetworkEnvironment.requestTimeout
    $0.timeoutIntervalForResource = NetworkEnvironment.resourceTimeout
  })
  
  /// Network Response에 대해 값을 검증하고 그 결과값을 리턴합니다.
  /// - Parameters:
  ///   - statusCode: http 상태 코드
  ///   - data: 응답값으로 받아온 `Data`
  ///   - type: Data 내부를 구성하는 타입
  ///   - decodingMode: 원하고자 하는 응답값의 데이터
  /// - Returns: GeneralResponse 또는 Plub Error
  ///
  /// 해당 메서드는 검증을 위해 사용됩니다.
  /// 요청값을 전달하고 응답받은 값을 처리하고 싶은 경우 `requestObject(_:type:completion:)`을 사용해주세요.
  func evaluateStatus<T: Codable>(
    by statusCode: Int,
    _ data: Data,
    type: T.Type
  ) -> Result<Any, PLUBError> {
    guard let decodedData = try? JSONDecoder().decode(GeneralResponse<T>.self, from: data) else {
      return .failure(.pathError)
    }
    switch statusCode {
    case 200..<300:
      switch decodingMode {
      case .data:
        return .success(decodedData.data ?? "None-Data")
      case .message:
        return .success(decodedData.message ?? "None-Data")
      case .general:
        return .success(decodedData)
      }
    case 400..<500:
      return .failure(.requestError(decodedData.statusCode!))
    case 500:
      return .failure(.serverError)
    default:
      return .failure(.networkError)
    }
  }
  
  /// PLUB 서버에 필요한 값을 동봉하여 요청합니다.
  /// - Parameters:
  ///   - target: Router를 채택한 인스턴스(instance)
  ///   - type: 응답 값에 들어오는 `data`를 파싱할 모델
  ///   - decodingMode: 원하고자 하는 응답값의 데이터
  ///   - completion: 요청에 따른 응답값을 처리하는 콜백 함수
  func sendRequest<T: Codable>(
    _ router: Router,
    type: T.Type = EmptyModel.self,
    completion: @escaping (Result<Any, PLUBError>) -> Void
  ) {
    session.request(router).responseData { response in
      switch response.result {
      case .success(let data):
        guard let statusCode = response.response?.statusCode else {
          fatalError("statusCode가 없는 응답값????")
        }
        let result = self.evaluateStatus(by: statusCode, data, type: type, decodingMode: decodingMode)
        completion(result)
      case .failure(let error):
        print(error)
      }
    }
  }
}

// MARK: - Network Enum Cases

extension BaseService {
  struct EmptyModel: Codable {
    
  }
}
