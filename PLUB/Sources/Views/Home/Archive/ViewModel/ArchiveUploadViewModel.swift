// 
//  ArchiveUploadViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/17.
//

import UIKit

import RxSwift
import RxCocoa

protocol ArchiveUploadViewModelType {
  // Input
  
  /// ViewController 단에서 initialized된 collectionView를 받습니다.
  var collectionViewObserver: AnyObserver<UICollectionView> { get }
  
  /// 선택된 셀의 IndexPath를 전달합니다.
  var selectedCellIndexPathObserver: AnyObserver<IndexPath> { get }
  
  /// 사용자가 아카이브에 올리기 위해 선택한 사진을 받습니다.
  var selectedImageObserver: AnyObserver<UIImage> { get }
  
  var completeButtonTappedObserver: AnyObserver<Void> { get }
  
  // Output
  
  /// 사진 업로드를 위해 바텀시트를 보여주어야할 때 사용됩니다.
  var presentPhotoBottomSheetObservable: Observable<Void> { get }
  
  /// 수정 및 업로드 버튼의 활성화 유무를 판단합니다.
  var buttonEnabledObservable: Observable<Bool> { get }
  
  var popViewControllerObservable: Observable<Void> { get }
}

final class ArchiveUploadViewModel {
  
  // MARK: - Properties
  
  private var dataSource: DataSource? {
    didSet {
      applyInitialSnapshots()
    }
  }
  
  private var archivesContents = [String]() {
    didSet {
      updateSnapshots()
      imagesStateSubject.onNext(archivesContents)
    }
  }
  
  // MARK: Subjects
  
  /// diffable datasource를 위한 collectionView 세팅 서브젝트
  private let setCollectionViewSubject          = PublishSubject<UICollectionView>()
  
  /// 선택된 CollectionViewCell의 IndexPath를 받고 처리하는 서브젝트
  private let selectedCellIndexPathSubject      = PublishSubject<IndexPath>()
  
  /// PhotoBottomSheet로부터 받은 이미지를 받고 처리하는 서브젝트
  private let selectedImageSubject              = PublishSubject<UIImage>()
  
  /// HeaderView의 제목 textfield를 Input으로 받아 가공하는 서브젝트
  private let archiveTitleSubject               = BehaviorSubject<String>(value: "")
  
  /// 이미지 CollectionViewCell의 cancelButton이 눌렸을 때 해당 이미지를 받아 처리하는 서브젝트
  private let deleteImageURLSubject             = PublishSubject<String>()
  
  /// 현재 저장되어있는 이미지의 상태를 받고 처리하는 서브젝트
  private let imagesStateSubject                = PublishSubject<[String]>()
  
  /// 업로드 또는 수정 버튼이 눌렸을 때를 받고, 파이프라인을 구성할 서브젝트
  private let completeButtonTappedSubject       = PublishSubject<Void>()
  
  /// 해당 ViewModel을 갖고있는 ViewController가 pop되어야할 때를 알려주기 위한 서브젝트
  private let popViewControllerSubject          = PublishSubject<Void>()
  
  // MARK: Use Cases
  
  private let getArchiveDetailUseCase: GetArchiveDetailUseCase
  private let uploadImageUseCase: UploadImageUseCase
  private let deleteImageUseCase: DeleteImageUseCase
  private let uploadArchiveUseCase: UploadArchiveUseCase
  
  init(
    getArchiveDetailUseCase: GetArchiveDetailUseCase,
    uploadImageUseCase: UploadImageUseCase,
    deleteImageUseCase: DeleteImageUseCase,
    uploadArchiveUseCase: UploadArchiveUseCase
  ) {
    self.getArchiveDetailUseCase = getArchiveDetailUseCase
    self.uploadImageUseCase = uploadImageUseCase
    self.deleteImageUseCase = deleteImageUseCase
    self.uploadArchiveUseCase = uploadArchiveUseCase
    
    fetchArchives()
    uploadImageAndUpdateView()
    removeImagesAndUpdateView()
    uploadAndDismissView()
  }
  
  private let disposeBag = DisposeBag()
}

// MARK: - Binding Methods

private extension ArchiveUploadViewModel {
  
  /// 아카이브를 조회한 결과 값을 토대로 View를 업데이트합니다.
  func fetchArchives() {
    
    Observable.combineLatest(getArchiveDetailUseCase.execute(), setCollectionViewSubject) {
      (content: $0, collectionView: $1)
    }
    .subscribe(with: self) { owner, tuple in
      owner.archivesContents = tuple.content.images
      owner.setCollectionView(tuple.collectionView, titleText: tuple.content.title)
      owner.archiveTitleSubject.onNext(tuple.content.title)
    }
    .disposed(by: disposeBag)
  }
  
  /// 선택된 이미지를 받아 업로드한 뒤 이미지를 뷰에 업데이트합니다.
  func uploadImageAndUpdateView() {
    selectedImageSubject
      .flatMap { [uploadImageUseCase] in
        uploadImageUseCase.execute(images: [$0], uploadType: .archive)
      }
      .compactMap {
        $0.files.first?.fileURL
      }
      .subscribe(with: self) { owner, imageLink in
        owner.archivesContents.append(imageLink)
      }
      .disposed(by: disposeBag)
  }
  
  /// 이미지를 제거하고, 뷰를 업데이트합니다.
  func removeImagesAndUpdateView() {
    deleteImageURLSubject
      .flatMap { [deleteImageUseCase] imageURL in
        deleteImageUseCase.execute(fileURL: imageURL, type: .archive).map { _ in imageURL }
      }
      .subscribe(with: self) { owner, imageURL in
        owner.archivesContents.removeAll { $0 == imageURL }
      }
      .disposed(by: disposeBag)
  }
  
  /// 아카이브 업로드를 시도하고, 성공했을 경우 ViewController를 Pop하는 로직을 처리합니다.
  func uploadAndDismissView() {
    completeButtonTappedSubject
      .withLatestFrom(archiveTitleSubject)
      .withLatestFrom(imagesStateSubject) {
        (title: $0, images: $1)
      }
      .flatMap { [uploadArchiveUseCase] tuple in
        uploadArchiveUseCase.execute(title: tuple.title, images: tuple.images).map { _ in Void() }
      }
      .bind(to: popViewControllerSubject)
      .disposed(by: disposeBag)
  }
}

// MARK: - ArchiveUploadViewModelType

extension ArchiveUploadViewModel: ArchiveUploadViewModelType {
  
  // MARK: Input
  
  var collectionViewObserver: AnyObserver<UICollectionView> {
    setCollectionViewSubject.asObserver()
  }
  
  var selectedCellIndexPathObserver: AnyObserver<IndexPath> {
    selectedCellIndexPathSubject.asObserver()
  }
  
  var selectedImageObserver: AnyObserver<UIImage> {
    selectedImageSubject.asObserver()
  }
  
  var completeButtonTappedObserver: AnyObserver<Void> {
    completeButtonTappedSubject.asObserver()
  }
  
  // MARK: Output
  
  var presentPhotoBottomSheetObservable: Observable<Void> {
    selectedCellIndexPathSubject
      .filter { [weak self] indexPath in
        self?.archivesContents.count == indexPath.item // `사진 추가`셀은 항상 마지막에 존재
      }
      .map { _ in Void() }
  }
  
  var buttonEnabledObservable: Observable<Bool> {
    .combineLatest(imagesStateSubject, archiveTitleSubject) {
      !$0.isEmpty && !$1.isEmpty
    }
  }
  
  var popViewControllerObservable: Observable<Void> {
    popViewControllerSubject.asObservable()
  }
}

// MARK: - Diffable DataSource

private extension ArchiveUploadViewModel {
  
  // MARK: Type Alias
  
  enum Section {
    case main
  }
  
  enum Item: Hashable {
    case upload           // 사진 추가
    case picture(String)  // 업로드된 사진
  }
  
  typealias DataSource                = UICollectionViewDiffableDataSource<Section, Item>
  typealias Snapshot                  = NSDiffableDataSourceSnapshot<Section, Item>
  
  typealias UploadedCellRegistration  = UICollectionView.CellRegistration<ArchiveUploadedPictureCell, Item>
  typealias UploadCellRegistration    = UICollectionView.CellRegistration<ArchiveUploadCell, Item>
  typealias HeaderRegistration        = UICollectionView.SupplementaryRegistration<ArchiveUploadHeaderView>
  
  // MARK: Snapshot & DataSource Part
  
  /// Collection View를 세팅하며, `DiffableDataSource`를 초기화하여 해당 Collection View에 데이터를 지닌 셀을 처리합니다.
  func setCollectionView(_ collectionView: UICollectionView, titleText: String) {
    
    let pictureRegistration = UploadedCellRegistration { [weak self] cell, _, item in
      guard case let .picture(imageLink) = item else { return }
      cell.configure(with: imageLink)
      cell.delegate = self
    }
    
    let uploadRegistration = UploadCellRegistration { cell, _, _ in
      
    }
    
    let headerRegistration = HeaderRegistration(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, _, _ in
      guard let self else { return }
      supplementaryView.configure(with: titleText)
      supplementaryView.delegate = self
    }
    
    // dataSource에 cell 등록
    dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
      if item == .upload {
        return collectionView.dequeueConfiguredReusableCell(using: uploadRegistration, for: indexPath, item: item)
      }
      return collectionView.dequeueConfiguredReusableCell(using: pictureRegistration, for: indexPath, item: item)
    }
    
    // dataSource에 headerView도 등록
    dataSource?.supplementaryViewProvider = .init { collectionView, _, indexPath in
      return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
    }
  }
  
  /// 초기 Snapshot을 설정합니다. DataSource가 초기화될 시 해당 메서드가 실행됩니다.
  /// 직접 이 메서드를 실행할 필요는 없습니다.
  func applyInitialSnapshots() {
    var snapshot = Snapshot()
    snapshot.appendSections([.main])
    let items = archivesContents.map { Item.picture($0) }
    snapshot.appendItems(items)
    snapshot.appendItems([.upload])
    dataSource?.apply(snapshot)
  }
  
  func updateSnapshots() {
    guard var snapshot = dataSource?.snapshot(),
          let addPictureItem = snapshot.itemIdentifiers.last // 사진 추가를 보여주기 위한 아이템
    else {
      return
    }
    
    // 함수가 끝나면 snapshot apply 적용
    defer {
      dataSource?.apply(snapshot)
    }
    
    var uploadedItems = Set(snapshot.itemIdentifiers
      .compactMap { item -> String? in
        guard case let .picture(imageLink) = item else { return nil }
        return imageLink
      })
    
    // 삭제될 아이템 찾기
    let itemsToRemove = uploadedItems.subtracting(archivesContents)
    snapshot.deleteItems(itemsToRemove.map({ Item.picture($0) }))
    uploadedItems.subtract(itemsToRemove)
    
    // 추가할 아이템 찾기
    let itemsToAdd = Set(archivesContents).subtracting(uploadedItems).map { Item.picture($0) }
    snapshot.appendItems(itemsToAdd)
    
    guard let lastItem = snapshot.itemIdentifiers.last
    else {
      return
    }
    
    snapshot.moveItem(addPictureItem, afterItem: lastItem)
  }
}

// MARK: - ArchiveUploadHeaderViewDelegate

extension ArchiveUploadViewModel: ArchiveUploadHeaderViewDelegate {
  func archiveTitle(text: String) {
    archiveTitleSubject.onNext(text)
  }
}

extension ArchiveUploadViewModel: ArchiveUploadedPictureCellDelegate {
  func cancelButtonTapped(imageURL: String) {
    deleteImageURLSubject.onNext(imageURL)
  }
}
