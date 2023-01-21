//
//  LocationBottomSheetViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/21.
//

import UIKit

protocol LocationBottomSheetDelegate: AnyObject {
  func selectLocation(placeName: String)
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

  private let noneView = NoLocationView()
  
  private let tableView = UITableView().then {
    $0.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.identifier)
    $0.separatorStyle = .none
    $0.showsVerticalScrollIndicator = false
    $0.backgroundColor = .background
    $0.rowHeight = 75
  }
  
  private var nextButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "다음")
    $0.isEnabled = false
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [titleLabel, searchView, searchCountLabel, noneView, tableView, nextButton].forEach {
      contentView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    contentView.snp.remakeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(639)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(16)
      $0.height.equalTo(23)
      $0.centerX.equalToSuperview()
    }
    
    searchView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.height.equalTo(40)
    }
    
    searchCountLabel.snp.makeConstraints {
      $0.top.equalTo(searchView.snp.bottom).offset(8)
      $0.trailing.equalToSuperview().inset(24)
      $0.height.equalTo(21)
    }
    
    noneView.snp.makeConstraints {
      $0.top.equalTo(searchView.snp.bottom).offset(64)
      $0.centerX.equalToSuperview()
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(175)
    }
    
    tableView.snp.makeConstraints {
      $0.top.equalTo(searchCountLabel.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
    
    nextButton.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(26)
      $0.height.width.equalTo(46)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
  }
  
  override func bind() {
    super.bind()
    searchView.textField.rx.text.orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.searchText)
      .disposed(by: disposeBag)
    
    searchView.textField.rx
      .controlEvent([.editingDidEndOnExit]).subscribe { _ in
        self.viewModel.refreshPagingData()
        self.viewModel.fetchLocationList(page: 1)
      }
      .disposed(by: disposeBag)
    
    viewModel.isEmptyList
      .withUnretained(self)
      .subscribe { owner, state in
        owner.tableView.isHidden = state
        owner.searchCountLabel.isHidden = state
      }
      .disposed(by: disposeBag)
    
    viewModel.totalCount
      .map({ count -> NSMutableAttributedString in
        return self.setSearchAttributeText(count: count)
      })
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
            subTitle: item.addressName ?? ""
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
      .subscribe{ [weak self] state in
        guard let self = self else { return }
        self.nextButton.isEnabled = state
      }
      .disposed(by: disposeBag)
    
    nextButton.rx.tap
      .asDriver(onErrorDriveWith: .empty())
      .drive(onNext: { _ in
        guard let data = self.viewModel.selectedLocation.value,
              let placeName = data.placeName else { return}
        self.delegate?.selectLocation(placeName: placeName)
        self.dismiss(animated: false)
      })
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
