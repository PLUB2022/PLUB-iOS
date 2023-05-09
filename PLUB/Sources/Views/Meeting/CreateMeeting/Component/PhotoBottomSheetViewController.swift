//
//  PhotoBottomSheetViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/17.
//

import UIKit

import CropViewController
import RxSwift
import RxCocoa
import SnapKit
import Then

protocol PhotoBottomSheetDelegate: AnyObject {
  func selectImage(image: UIImage)
}

final class PhotoBottomSheetViewController: BottomSheetViewController {
  weak var delegate: PhotoBottomSheetDelegate?
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
    $0.backgroundColor = .background
  }
  
  private let cameraView = BottomSheetListView(
    text: "카메라로 촬영",
    image: "camera"
  )
  
  private let albumView = BottomSheetListView(
    text: "앨범에서 사진 업로드",
    image: "selectPhotoBlack"
  )
  
  private lazy var photoPicker = UIImagePickerController().then {
    $0.delegate = self
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    contentView.addSubview(contentStackView)
    
    [cameraView, albumView].forEach {
      contentStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    contentStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Metrics.Margin.top)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Metrics.Margin.horizontal)
      $0.bottom.equalToSuperview().inset(Metrics.Margin.bottom)
    }
    
    cameraView.snp.makeConstraints {
      $0.height.equalTo(Metrics.Size.height)
    }
    
    albumView.snp.makeConstraints {
      $0.height.equalTo(Metrics.Size.height)
    }
  }
  
  override func bind() {
    super.bind()
    cameraView.button.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.photoPicker.sourceType = .camera
        owner.present(owner.photoPicker, animated: true)
      }
      .disposed(by: disposeBag)
    
    albumView.button.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.photoPicker.sourceType = .photoLibrary
        owner.present(owner.photoPicker, animated: true)
      }
      .disposed(by: disposeBag)
  }
}

extension PhotoBottomSheetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    guard let selectedImage = info[.originalImage] as? UIImage else { return }
    
    picker.dismiss(animated: true) {
      let cropViewController = CropViewController(croppingStyle: .default, image: selectedImage).then {
        $0.aspectRatioPreset = .presetSquare
        $0.aspectRatioLockEnabled = false
        $0.toolbarPosition = .bottom
        $0.doneButtonTitle = "계속"
        $0.cancelButtonTitle = "취소"
        $0.delegate = self
      }
      self.present(cropViewController, animated: true)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true) {
      self.dismiss(animated: true)
    }
  }
}

// MARK: - CropViewControllerDelegate

extension PhotoBottomSheetViewController: CropViewControllerDelegate {
  func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
    cropViewController.dismiss(animated: true)
  }
  
  func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
    cropViewController.dismiss(animated: true)
    delegate?.selectImage(image: image)
    self.dismiss(animated: true)
  }
}
