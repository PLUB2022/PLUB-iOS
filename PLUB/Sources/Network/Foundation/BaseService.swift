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
    type: T.Type,
    decodingMode: DecodingMode
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
      return .failure(.requestError)
    case 500:
      return .failure(.serverError)
    default:
      return .failure(.networkError)
    }
  }
  
  /// 응답값만을 검증할 때 사용됩니다.
  /// - Parameter statusCode: HTTP 상태코드
  /// - Returns: success or failure
  func evaluateStatusWithoutPayload(by statusCode: Int?) -> Result<Any, PLUBError> {
    guard let statusCode = statusCode else { return .failure(.pathError) }
    switch statusCode {
    case 200..<300:
      return .success(())
    case 400..<500:
      return .failure(.requestError)
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
    _ target: Router,
    type: T.Type,
    decodingMode: DecodingMode,
    completion: @escaping (Result<Any, PLUBError>) -> Void
  ) {
    session.request(target).responseData { response in
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
  
  /// PLUB 서버에 요청을 전달할 때 사용되며 응답값이 필요없을 때 사용합니다.
  /// - Parameters:
  ///   - router: Router를 채택한 인스턴스(instance)
  ///   - completion: 요청에 따른 응답값을 처리하는 콜백 함수
  ///
  /// 요청을 보내되 제대로 요청이 처리되었는지만을 확인하고 싶은 경우가 있습니다.
  /// 그럴 때 해당 메서드를 사용하시면 됩니다.
  /// 예를 들어, `회원 탈퇴`나 `로그 아웃`과 같은 경우가 이에 속합니다.
  func sendRequestWithoutPayload(_ router: Router, completion: @escaping (Result<Any, PLUBError>) -> Void) {
    session.request(router).responseData { response in
      completion(self.evaluateStatusWithoutPayload(by: response.response?.statusCode))
    }
  }
}

// MARK: - Network Enum Cases

extension BaseService {
  
  enum DecodingMode {
    
    /// 응답으로 받은 값을 전부 전달합니다.
    case general
    
    /// 응답에서 `data`가 key인 값을 추출하여 전달합니다.
    case data
    
    /// 응답에서 `message`가 key인 값을 추출하여 전달합니다.
    case message
  }
}
