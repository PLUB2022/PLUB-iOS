//
//  PhotoBottomSheetViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/17.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

protocol PhotoBottomSheetDelegate: AnyObject {
  func selectImage(image: UIImage)
}

final class PhotoBottomSheetViewController: BottomSheetViewController {
  weak var delegate: PhotoBottomSheetDelegate?
  
  private let lineView = UIView().then {
    $0.backgroundColor = .mediumGray
    $0.layer.cornerRadius = 2
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
    $0.backgroundColor = .background
  }
  
  private let cameraView = PhotoBottomSheetListView(
    text: "카메라로 촬영",
    image: "camera"
  )
  
  private let albumView = PhotoBottomSheetListView(
    text: "앨범에서 사진 업로드",
    image: "selectPhotoBlack"
  )
  
  private lazy var photoPicker = UIImagePickerController().then {
    $0.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [lineView, contentStackView].forEach {
      contentView.addSubview($0)
    }
    
    [cameraView, albumView].forEach {
      contentStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    lineView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(8)
      $0.height.equalTo(4.33)
      $0.width.equalTo(52)
      $0.centerX.equalToSuperview()
    }
    
    contentStackView.snp.makeConstraints {
      $0.top.equalTo(lineView.snp.bottom).offset(26)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(78)
    }
    
    cameraView.snp.makeConstraints {
      $0.height.equalTo(52)
    }
    
    albumView.snp.makeConstraints {
      $0.height.equalTo(52)
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
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
  ) {
    guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
    
    picker.dismiss(animated: false, completion: {
      self.delegate?.selectImage(image: selectedImage)
      self.dismiss(animated: false)
    })
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: false, completion: {
      self.dismiss(animated: false)
    })
  }
}
