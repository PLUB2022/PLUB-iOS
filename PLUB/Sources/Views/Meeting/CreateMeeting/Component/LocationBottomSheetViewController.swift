//
//  LocationBottomSheetViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/21.
//

import UIKit

import SnapKit
import Then

protocol LocationBottomSheetDelegate: AnyObject {
  func selectLocation(location: Location)
}

final class LocationBottomSheetViewController: BottomSheetViewController {
  weak var delegate: LocationBottomSheetDelegate?
  private let viewModel =  MeetingLocationViewModel()
  
  private let titleLabel = UILabel().then {
    $0.text = "장소 검색"
    $0.textColor = .black
    $0.font = .h5
  }
  
  private let searchView = SearchView()
  
  private let searchCountLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .body2
  }
  
  private let firstView = LocationBaseView()
  
  private let noneView = NoLocationView().then {
    $0.isHidden = true
  }
  
  private let tableView = UITableView().then {
    $0.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.identifier)
    $0.separatorStyle = .none
    $0.showsVerticalScrollIndicator = false
    $0.backgroundColor = .background
    $0.isHidden = true
  }
  
  private let nextButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "확인")
    $0.isEnabled = false
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [titleLabel, searchView, searchCountLabel, firstView, noneView, tableView, nextButton].forEach {
      contentView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(16)
      $0.height.equalTo(23)
      $0.centerX.equalToSuperview()
    }
    
    searchView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(Metrics.Margin.horizontal)
      $0.height.equalTo(40)
    }
    
    searchCountLabel.snp.makeConstraints {
      $0.top.equalTo(searchView.snp.bottom).offset(8)
      $0.trailing.equalTo(searchView.snp.trailing)
      $0.height.equalTo(21)
    }
    
    firstView.snp.makeConstraints {
      $0.top.equalTo(searchView.snp.bottom).offset(64)
      $0.centerX.equalToSuperview()
    }
    
    noneView.snp.makeConstraints {
      $0.top.equalTo(searchView.snp.bottom).offset(64)
      $0.centerX.equalToSuperview()
    }
    
    tableView.snp.makeConstraints {
      $0.top.equalTo(searchCountLabel.snp.bottom).offset(16)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Metrics.Margin.horizontal)
      $0.bottom.equalTo(nextButton.snp.top).offset(-6)
      $0.height.equalTo(352)
    }
    
    nextButton.snp.makeConstraints {
      $0.directionalHorizontalEdges.bottom.equalToSuperview().inset(Metrics.Margin.horizontal)
      $0.height.equalTo(Metrics.Size.button)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    if let sheet = sheetPresentationController {
      sheet.prefersGrabberVisible = false
    }
  }
  
  override func bind() {
    super.bind()
    searchView.textField.rx.text.orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.searchText)
      .disposed(by: disposeBag)
    
    searchView.textField.rx
      .controlEvent([.editingDidEndOnExit])
      .subscribe(with: self) { owner, _ in
        owner.viewModel.refreshPagingData()
        owner.viewModel.fetchLocationList(page: 1)
      }
      .disposed(by: disposeBag)
    
    searchView.textField.rx
      .controlEvent([.editingDidBegin])
      .subscribe(with: self) { owner, _ in
        owner.searchView.setupStyles(state: true)
      }
      .disposed(by: disposeBag)
    
    searchView.textField.rx
      .controlEvent([.editingDidEnd])
      .filter { [weak self] in self?.searchView.textField.text?.isEmpty ?? false }
      .subscribe(with: self) { owner, _ in
        owner.searchView.setupStyles(state: false)
      }
      .disposed(by: disposeBag)
    
    viewModel.isEmptyList
      .withUnretained(self)
      .subscribe { owner, state in
        owner.noneView.isHidden = !state
        if state {
          let searchText = owner.searchView.textField.text ?? ""
          owner.noneView.setTitleAttributeText(searchText: searchText)
        }
        owner.tableView.isHidden = state
        owner.searchCountLabel.isHidden = state
      }
      .disposed(by: disposeBag)
    
    viewModel.totalCount
      .compactMap { [weak self] in
        return self?.setSearchAttributeText(count: $0)
      }
      .bind(to: searchCountLabel.rx.attributedText)
      .disposed(by: disposeBag)
    
    viewModel.locationList
      .bind(to: tableView.rx.items) { tableView, row, item -> UITableViewCell in
        guard let cell = tableView.dequeueReusableCell(
          withIdentifier: "LocationTableViewCell",
          for: IndexPath(row: row, section: 0)
        ) as? LocationTableViewCell,
              let item = item
        else { return UITableViewCell() }
        cell.setupData(
          with: LocationTableViewCellModel(
            title: item.placeName ?? "",
            subTitle: item.address ?? ""
          )
        )
        return cell
      }
      .disposed(by: disposeBag)
    
    tableView.rx.didScroll
      .subscribe { [weak self] _ in
        guard let self = self else { return }
        let offsetY = self.tableView.contentOffset.y
        let contentHeight = self.tableView.contentSize.height
        if offsetY > (contentHeight - self.tableView.frame.size.height) {
          self.viewModel.fetchMoreData.onNext(())
        }
      }
      .disposed(by: disposeBag)
    
    tableView.rx.modelSelected(KakaoLocationDocuments.self)
      .bind(to: viewModel.selectedLocation)
      .disposed(by: disposeBag)
    
    viewModel.nextButtonEnabled
      .distinctUntilChanged()
      .subscribe { [weak self] state in
        guard let self = self else { return }
        self.nextButton.isEnabled = state
      }
      .disposed(by: disposeBag)
    
    nextButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        guard let data = owner.viewModel.selectedLocation.value,
              let address = data.address,
              let roadAddress = data.roadAddress,
              let placeName = data.placeName,
              let positionX = data.placePositionX,
              let positionY = data.placePositionY else { return }
        owner.delegate?.selectLocation(
          location: Location(
            address: address,
            roadAddress: roadAddress,
            placeName: placeName,
            positionX: Double(positionX) ?? 0,
            positionY: Double(positionY) ?? 0
          )
        )
        owner.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  private func setSearchAttributeText(count: Int) -> NSMutableAttributedString {
    let blackCharacters = NSAttributedString(
      string: "검색결과 ",
      attributes: [.foregroundColor: UIColor.black]
    )
    
    let purpleCharacters = NSAttributedString(
      string: "\(count)개",
      attributes: [.foregroundColor: UIColor.main]
    )
    
    return NSMutableAttributedString(attributedString: blackCharacters).then {
      $0.append(purpleCharacters)
    }
  }
}
