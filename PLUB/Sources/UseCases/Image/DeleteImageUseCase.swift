// 
//  DeleteImageUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/23.
//

import RxSwift

protocol DeleteImageUseCase {
  func execute(fileURL: String, type: ImageType) -> Observable<BaseService.EmptyModel>
}

final class DefaultDeleteImageUseCase: DeleteImageUseCase {
  
  func execute(fileURL: String, type: ImageType) -> Observable<BaseService.EmptyModel> {
    ImageService.shared.deleteImage(fileURL: fileURL, imageType: type)
  }
}
