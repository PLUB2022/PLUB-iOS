//
//  ImageService.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/25.
//

import UIKit

import Alamofire
import RxCocoa
import RxSwift

enum ImageServiceType {
  case upload
  case update
}

final class ImageService: BaseService {
  static let shared = ImageService()
  
  private override init() { }
}

extension ImageService {
  func uploadImage(
    images: [UIImage],
    params: UploadImageRequest
) -> PLUBResult<UploadImageResponse> {
    return sendRequestWithImage(
      setUpImageData(
        images: images,
        params: params.toDictionary
      ),
      ImageRouter.uploadImage,
      type: UploadImageResponse.self
    )
  }
  
  func updateImage(
    images: [UIImage],
    params: UpdateImageRequest
) -> PLUBResult<UploadImageResponse> {
    return sendRequestWithImage(
      setUpImageData(
        images: images,
        params: params.toDictionary,
        type: .update
      ),
      ImageRouter.updateImage,
      type: UploadImageResponse.self
    )
  }
  
  private func setUpImageData(
    images: [UIImage],
    params: [String: Any],
    type: ImageServiceType = .upload
  ) -> MultipartFormData {
    let formData = MultipartFormData()

    for image in images {
      guard let imageData = image.jpegData(compressionQuality: 0.1) else { continue }
      formData.append(
        imageData,
        withName: type == .upload ? "files" : "newFiles",
        fileName: "\(image).jpeg",
        mimeType: "image/jpeg"
      )
    }
    
    for (key, value) in params {
      guard let value = value as? String else { continue }
      formData.append(
        Data(value.utf8),
        withName: key
      )
    }
    
    return formData
  }
}
