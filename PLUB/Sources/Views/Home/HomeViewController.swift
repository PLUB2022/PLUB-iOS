import UIKit

import RxSwift
import SnapKit
import Then

enum HomeType { // 사용자 관심사 선택 유무
  case selected
  case nonSelected
  
  var height: NSCollectionLayoutDimension {
    switch self {
    case .selected:
      return .absolute(32)
    case .nonSelected:
      return .absolute(56)
    }
  }
  
  var bottomInset: CGFloat {
    switch self {
    case .selected:
      return 24
    case .nonSelected:
      return 8
    }
  }
}

enum HomeSectionType: CaseIterable { // 홈 화면 섹션 타입
  case mainCategoryList
  case interestSelect
  case recommendedMeeting
}

final class HomeViewController: BaseViewController {
  
  private let viewModel: HomeViewModelType
  private var mainCategoryList: [MainCategory] = [] {
    didSet {
      self.homeCollectionView.reloadSections([0])
    }
  }
  
  private var homeType: HomeType = .selected {
    didSet {
      self.homeCollectionView.reloadSections([1])
    }
  }
  
  private var selectedCategoryCollectionViewCellModel: [SelectedCategoryCollectionViewCellModel] = [] {
    didSet {
      self.homeCollectionView.reloadSections([2])
    }
  }
  
  init(viewModel: HomeViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private lazy var homeCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sec, env -> NSCollectionLayoutSection? in
      guard let `self` = self else {
        return nil
      }
      return self.createCompositionalSection(homeCollectionType: HomeSectionType.allCases[sec])
    }).then {
      $0.backgroundColor = .background
      $0.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
      $0.register(InterestSelectCollectionViewCell.self, forCellWithReuseIdentifier: InterestSelectCollectionViewCell.identifier)
      $0.register(SelectedCategoryChartCollectionViewCell.self, forCellWithReuseIdentifier: SelectedCategoryChartCollectionViewCell.identifier)
      $0.register(InterestSelectCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: InterestSelectCollectionHeaderView.identifier)
      $0.register(HomeMainCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeMainCollectionHeaderView.identifier)
    }
  
  // MARK: - Configuration
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(homeCollectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    homeCollectionView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(16)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .background
    self.navigationController?.navigationBar.tintColor = .black
    self.navigationController?.navigationBar.backgroundColor = .background
    self.navigationItem.rightBarButtonItems = [
      UIBarButtonItem(
        image: UIImage(named: "blackBookmark"),
        style: .done,
        target: self,
        action: #selector(didTappedSearchButton)
      ),
      UIBarButtonItem(
        image: UIImage(named: "search"),
        style: .done,
        target: self,
        action: #selector(didTappedSearchButton)
      )
    ]
    
    let logoImageView = UIImageView().then {
      $0.image = UIImage(named: "plubIcon522x147")
      $0.contentMode = .scaleAspectFill
    }
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoImageView)
    
  }
  
  override func bind() {
    super.bind()
    viewModel.fetchedMainCategoryList
      .drive(rx.mainCategoryList)
      .disposed(by: disposeBag)
    
    viewModel.isSelectedInterest
      .withUnretained(self)
      .emit(onNext: { owner, isSelectedInterest in
        owner.homeType = isSelectedInterest ? .selected : .nonSelected
      })
      .disposed(by: disposeBag)
    
    viewModel.updatedRecommendationCellData
      .drive(rx.selectedCategoryCollectionViewCellModel)
      .disposed(by: disposeBag)
    
    viewModel.isBookmarked.emit(onNext: { isBookmarked in
      print("해당 모집글을 북마크 \(isBookmarked)")
    })
    .disposed(by: disposeBag)
    
    homeCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
    homeCollectionView.rx.setDataSource(self).disposed(by: disposeBag)
  }
  
  @objc private func didTappedSearchButton() {
    let vc = SearchInputViewController()
    vc.navigationItem.largeTitleDisplayMode = .never
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  private func createCompositionalSection(homeCollectionType: HomeSectionType) -> NSCollectionLayoutSection {
    switch homeCollectionType {
    case .mainCategoryList:
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .fractionalHeight(1)
        )
      )
      
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(85)),
        subitem: item,
        count: 4
      )
      
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(120)
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .none
      section.boundarySupplementaryItems = [header]
      section.contentInsets = .init(top: .zero, leading: .zero, bottom: 37, trailing: .zero)
      return section
      
    case .interestSelect:
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .fractionalHeight(1)
        )
      )
      
      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(176)
        ),
        subitem: item,
        count: 1
      )
      
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: homeType.height
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.boundarySupplementaryItems = [header]
      section.contentInsets = .init(top: .zero, leading: .zero, bottom: homeType.bottomInset, trailing: .zero)
      return section
      
    case .recommendedMeeting:
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .fractionalHeight(1)
        )
      )
      
      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(176)
        ),
        subitem: item,
        count: 1
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = 12
      return section
    }
  }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return HomeSectionType.allCases.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch HomeSectionType.allCases[section] {
    case .mainCategoryList:
      return mainCategoryList.count
    case .interestSelect:
      switch homeType {
      case .nonSelected:
        return 1
      case .selected:
        return 0
      }
    case .recommendedMeeting:
      return selectedCategoryCollectionViewCellModel.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let homeCollectionType = HomeSectionType.allCases[indexPath.section]
    
    switch homeCollectionType {
    case .mainCategoryList:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as? HomeCollectionViewCell ?? HomeCollectionViewCell()
      cell.configureUI(with: mainCategoryList[indexPath.row])
      return cell
    case.interestSelect:
      switch homeType {
      case .selected:
        return UICollectionViewCell()
      case .nonSelected:
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InterestSelectCollectionViewCell.identifier, for: indexPath) as? InterestSelectCollectionViewCell ?? InterestSelectCollectionViewCell()
        cell.delegate = self
        return cell
      }
    case .recommendedMeeting:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedCategoryChartCollectionViewCell.identifier, for: indexPath) as? SelectedCategoryChartCollectionViewCell ?? SelectedCategoryChartCollectionViewCell()
      cell.configureUI(with: selectedCategoryCollectionViewCellModel[indexPath.row])
      cell.delegate = self
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let homeSection = HomeSectionType.allCases[indexPath.section]
    switch homeSection {
    case .mainCategoryList:
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeMainCollectionHeaderView.identifier, for: indexPath) as? HomeMainCollectionHeaderView ?? HomeMainCollectionHeaderView()
      return header
    case .interestSelect:
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: InterestSelectCollectionHeaderView.identifier, for: indexPath) as? InterestSelectCollectionHeaderView ?? InterestSelectCollectionHeaderView()
      header.configureUI(with: homeType)
      return header
    case .recommendedMeeting:
      return UICollectionReusableView()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let homeSection = HomeSectionType.allCases[indexPath.section]
    switch homeSection {
    case .mainCategoryList:
      let vc = SelectedCategoryViewController(viewModel: SelectedCategoryViewModel(), categoryID: "")
      vc.title = mainCategoryList[indexPath.row].name
      vc.navigationItem.largeTitleDisplayMode = .never
      self.navigationController?.pushViewController(vc, animated: true)
    case .interestSelect:
      let vc = RegisterInterestViewController(viewModel: RegisterInterestViewModel())
      vc.navigationItem.largeTitleDisplayMode = .never
      self.navigationController?.pushViewController(vc, animated: true)
    case .recommendedMeeting:
      let vc = DetailRecruitmentViewController(plubbingId: selectedCategoryCollectionViewCellModel[indexPath.row].plubbingId)
      vc.navigationItem.largeTitleDisplayMode = .never
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
}

extension HomeViewController: InterestSelectCollectionViewCellDelegate {
  func didTappedRegisterInterestView() {
    let vc = RegisterInterestViewController(viewModel: RegisterInterestViewModel())
    vc.navigationItem.largeTitleDisplayMode = .never
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension HomeViewController: SelectedCategoryChartCollectionViewCellDelegate {
  func didTappedBookmarkButton(plubbingID: String) {
    viewModel.tappedBookmark.onNext(plubbingID)
  }
}
