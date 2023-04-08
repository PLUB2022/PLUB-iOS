//
//  NetworkResult.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/16.
//

import Foundation

import enum Alamofire.AFError

@available(*, deprecated)
enum NetworkResult<T> {
  
  /// 성공
  case success(T)
  
  /// 요청 값에 문제가 발생한 경우 발생되는 에러입니다.
  ///
  /// 400~499 대의 응답코드가 이 에러에 속합니다.
  case requestError(T)
  
  /// 서버에 문제가 생겼을 때 발생됩니다.
  ///
  /// 500번대 응답코드가 이 에러에 속합니다.
  case serverError
  
  /// 사용자의 네트워크에 문제가 있어 값을 가져오지 못하는 경우
  case networkError
  
  /// 경로 에러, path가 잘못된 경우
  case pathError
}

/// PLUB 에러 모음
enum PLUBError<T>: Error {
  
  /// 요청 값에 문제가 발생한 경우 발생되는 에러입니다.
  ///
  /// 400~499 대의 응답코드가 이 에러에 속합니다.
  case requestError(T)
  
  /// 서버에 문제가 생겼을 때 발생됩니다.
  ///
  /// 500번대 응답코드가 이 에러에 속합니다.
  case serverError
  
  /// 사용자의 네트워크에 문제가 있어 값을 가져오지 못하는 경우
  case networkError
  
  /// 서버로부터 받아온 값과 Codable 모델 간 디코딩 문제가 발생한 경우
  case decodingError(raw: Data)
  
  /// Alamofire에서 직접 내려주는 에러
  case alamofireError(AFError)
  
  /// 알 수 없는 에러
  case unknownedError
}
