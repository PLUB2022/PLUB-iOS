import UIKit
import Then
import SnapKit
import RxSwift

enum HomeType { // 사용자 관심사 선택 유무
  case selected
  case nonSelected
}

enum HomeSectionType: CaseIterable { // 홈 화면 섹션 타입
  case interest
  case recommendedMeeting
}

final class HomeViewController: BaseViewController {
  
  private var homeType: HomeType = .nonSelected
  
  private lazy var homeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sec, env -> NSCollectionLayoutSection? in
    guard let `self` = self else {
      return nil
    }
    return type(of: self).createCompositionalSection(homeCollectionType: HomeSectionType.allCases[sec])
  }).then {
    $0.backgroundColor = .systemBackground
    $0.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
    $0.register(RecommendedMeetingCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedMeetingCollectionViewCell.identifier)
    $0.register(RecommendedMeetingHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RecommendedMeetingHeaderView.identifier)
  }
  
  // MARK: - Configuration
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(homeCollectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    homeCollectionView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .systemBackground
    self.navigationController?.navigationBar.tintColor = .black
    self.navigationItem.rightBarButtonItems = [
      UIBarButtonItem(
        image: UIImage(named: "BookMark"),
        style: .done,
        target: self,
        action: #selector(didTappedSearchButton)
      ),
      UIBarButtonItem(
        image: UIImage(named: "Union"),
        style: .done,
        target: self,
        action: #selector(didTappedSearchButton)
      )
    ]
    
    let logoImageView = UIImageView().then {
      $0.image = UIImage(named: "Vector")
      $0.contentMode = .scaleAspectFill
    }
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoImageView)
  }
  
  override func bind() {
    super.bind()
    homeCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
    homeCollectionView.rx.setDataSource(self).disposed(by: disposeBag)
  }
  
  @objc private func didTappedSearchButton() {
    print("search")
  }
  
  private static func createCompositionalSection(homeCollectionType: HomeSectionType) -> NSCollectionLayoutSection {
    switch homeCollectionType {
    case .interest:
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .fractionalHeight(1)
        )
      )
      item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 7, bottom: 1, trailing: 7)
      
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(120)),
        subitem: item,
        count: 4
      )
      group.interItemSpacing = NSCollectionLayoutSpacing.fixed(1)
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .none
      return section
      
    case .recommendedMeeting:
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .fractionalHeight(1)
        )
      )
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(150)
        ),
        subitem: item,
        count: 1
      )
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(90)
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      let section = NSCollectionLayoutSection(group: group)
      section.boundarySupplementaryItems = [header]
      return section
    }
  }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return HomeSectionType.allCases.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch homeType {
    case .nonSelected:
      switch HomeSectionType.allCases[section] {
      case .interest:
        return InterestCollectionType.allCases.count
      case .recommendedMeeting:
        return 1
      }
    case .selected:
      return 0
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let homeCollectionType = HomeSectionType.allCases[indexPath.section]
    
    switch homeCollectionType {
    case .interest:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as? HomeCollectionViewCell ?? HomeCollectionViewCell()
      cell.configureUI(with: InterestCollectionType.allCases[indexPath.row])
      return cell
    case .recommendedMeeting:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedMeetingCollectionViewCell.identifier, for: indexPath) as? RecommendedMeetingCollectionViewCell ?? RecommendedMeetingCollectionViewCell()
      cell.delegate = self
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch homeType {
    case .selected:
      return UICollectionReusableView()
    case .nonSelected:
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RecommendedMeetingHeaderView.identifier, for: indexPath) as? RecommendedMeetingHeaderView ?? RecommendedMeetingHeaderView()
      return header
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let vc = SelectedCategoryViewController(viewModel: SelectedCategoryViewModel())
    vc.title = InterestCollectionType.allCases[indexPath.row].title
    vc.navigationItem.largeTitleDisplayMode = .never
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension HomeViewController: RecommendedMeetingCollectionViewCellDelegate {
  func didTappedRegisterInterestView() {
    let vc = RegisterInterestViewController(viewModel: RegisterInterestViewModel())
    vc.navigationItem.largeTitleDisplayMode = .never
    self.navigationController?.pushViewController(vc, animated: true)
  }
}
