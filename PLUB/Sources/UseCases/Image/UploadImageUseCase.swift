// 
//  UploadImageUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/23.
//

import UIKit

import RxSwift

protocol UploadImageUseCase {
  func execute(images: [UIImage], uploadType: ImageType) -> Observable<UploadImageResponse>
}

final class DefaultUploadImageUseCase: UploadImageUseCase {
  
  func execute(images: [UIImage], uploadType: ImageType) -> Observable<UploadImageResponse> {
    ImageService.shared.uploadImage(images: images, params: UploadImageRequest(type: uploadType))
      .compactMap { result in
        guard case let .success(response) = result else {
          return nil
        }
        return response.data
      }
  }
}
