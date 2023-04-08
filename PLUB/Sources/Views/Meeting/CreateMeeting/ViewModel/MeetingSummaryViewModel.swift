//
//  MeetingSummaryViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/01.
//

import UIKit

import RxSwift
import RxCocoa

final class MeetingSummaryViewModel {
  private let disposeBag = DisposeBag()
  
  // Data
  let meetingData: CreateMeetingRequest
  let mainImage: UIImage?
  let categoryNames: [String]
  let time: String
  
  // Output
  let presentSuccessPage = PublishSubject<Void>()
  
  init(
    meetingData: CreateMeetingRequest,
    mainImage: UIImage?,
    categoryNames: [String],
    time: String
  ) {
    self.meetingData = meetingData
    self.mainImage = mainImage
    self.categoryNames = categoryNames
    self.time = time
  }
  
  func createMeeting() {
    if let image = mainImage {
      requestImageUpload(image: image)
    } else {
      requestCreateMeeting(with: meetingData)
    }
  }
  
  private func requestImageUpload(image: UIImage) {
    ImageService.shared.uploadImage(
      images: [image],
      params: UploadImageRequest(type: .plubbingMain)
    )
    .withUnretained(self)
    .subscribe(onNext: { owner, result in
      switch result {
      case .success(let model):
        guard let data = model.data,
              let fileUrl = data.files.first?.fileURL else { return }
        var request = owner.meetingData
        request.mainImage = fileUrl
        owner.requestCreateMeeting(with: request)
        
      default: break// TODO: 수빈 - PLUB 에러 Alert 띄우기
      }
    })
      .disposed(by: disposeBag)
  }
  
  private func requestCreateMeeting(with request: CreateMeetingRequest) {
    MeetingService.shared.createMeeting(request: request)
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          owner.presentSuccessPage.onNext(())
          print(model.data?.plubbingID)
        default: break // TODO: 수빈 - PLUB 에러 Alert 띄우기
        }
      })
      .disposed(by: disposeBag)
  }
}
