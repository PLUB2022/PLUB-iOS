//
//  Router.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/13.
//

import Foundation

import Alamofire

/// Base Router Protocol입니다.
///
/// 추가 네트워킹 작업이 필요한 경우 `Router`을 채택하는 다른 Router를 구현하시면 됩니다.
protocol Router: URLRequestConvertible {
  /// 공통 base URL
  var baseURL: String { get }
  
  /// HTTP Request method
  var method: HTTPMethod { get }
  
  /// HTTP Path
  var path: String { get }
  
  /// 요청시 넣을 파라미터입니다.
  ///
  /// body값이거나 query값을 설정할 때 이용합니다.
  var parameters: Parameters? { get }
  
  
  /// 헤더 값을 설정할 때 사용됩니다.
  var headers: HTTPHeaders { get }
}

// MARK: - Default Value Settings

extension Router {
  
  var baseURL: String {
    return URLConstants.baseURL
  }
  
  var parameters: Parameters? {
    return nil
  }
  
  var headers: HTTPHeaders {
    return .default
  }
  
  func asURLRequest() throws -> URLRequest {
    let url = try baseURL.asURL()
    
    var request = try URLRequest(url: url.appendingPathComponent(path), method: method)
    
    // check headers
    request.headers = headers
    
    // check parameters
    guard let parameters = parameters else { return request }
    
    //FIXME: 승현 - parameter 작업 수정 필요
    // method 값에 의존적임, 원하지 않는 작업이 될 수도 있다.
    switch method {
    case .post: // body
      request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
    default: // query
      var components = URLComponents(string: url.appendingPathComponent(path).absoluteString)
      components?.queryItems = parameters.map { URLQueryItem(name: $0, value: "\($1)") }
      request.url = components?.url
    }
    
    return request
  }
}
