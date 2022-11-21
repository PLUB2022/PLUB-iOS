import UIKit
import Then
import SnapKit

enum InterestCollectionType: CaseIterable {
    case Art
    case SportFitness
    case Investment
    case LanguageStudy
    case Culture
    case Food
    case Employment
    case Computer
    
    var title: String {
        switch self {
        case .Art:
            return "예술"
        case .SportFitness:
            return "스포츠/피트니스"
        case .Investment:
            return "재테크/투자"
        case .LanguageStudy:
            return "어학"
        case .Culture:
            return "문화"
        case .Food:
            return "음식"
        case .Employment:
            return "취업/창업"
        case .Computer:
            return "컴퓨터"
        }
    }
    
    var imageNamed: String {
        switch self {
        case .Art:
            return "ic_outline-palette"
        case .SportFitness:
            return "ic_outline-sports-basketball"
        case .Investment:
            return "ri_money-dollar-circle-line"
        case .LanguageStudy:
            return "fluent_local-language-24-filled"
        case .Culture:
            return "ph_film-strip"
        case .Food:
            return "fluent_food-pizza-24-regular"
        case .Employment:
            return "gg_work-alt"
        case .Computer:
            return "mi_computer"
        }
    }
}

enum HomeCollectionType: CaseIterable {
    case Interest
    case RecommendedMeeting
}

final class HomeViewController: BaseViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { [weak self] sec, env -> NSCollectionLayoutSection? in
            guard let `self` = self else {
                return nil
            }
            return type(of: self).createCompositionalSection(homeCollectionType: HomeCollectionType.allCases[sec])
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView(collectionView)
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(named: "Vector 24"),
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
    
    // MARK: - Configuration
    
    override func setupLayouts() {
        super.setupLayouts()
        view.addSubview(collectionView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setupStyles() {
        super.setupStyles()
        view.backgroundColor = .systemBackground
    }
    
    override func bind() {
        super.bind()
    }
    
    @objc private func didTappedSearchButton() {
        print("search")
    }
    
    private func setCollectionView(_ collection: UICollectionView) {
        collectionView.delegate = self
        collection.dataSource = self
        collection.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
        collectionView.register(RecommendedMeetingCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedMeetingCollectionViewCell.identifier)
        collectionView.register(RecommendedMeetingHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RecommendedMeetingHeaderView.identifier)
    }
    
    private static func createCompositionalSection(homeCollectionType: HomeCollectionType) -> NSCollectionLayoutSection {
        switch homeCollectionType {
        case .Interest:
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
            
        case .RecommendedMeeting:
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
        return HomeCollectionType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch HomeCollectionType.allCases[section] {
        case .Interest:
            return InterestCollectionType.allCases.count
        case .RecommendedMeeting:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let homeCollectionType = HomeCollectionType.allCases[indexPath.section]
        
        switch homeCollectionType {
        case .Interest:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as? HomeCollectionViewCell ?? HomeCollectionViewCell()
            cell.configureUI(with: InterestCollectionType.allCases[indexPath.row])
            return cell
        case .RecommendedMeeting:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedMeetingCollectionViewCell.identifier, for: indexPath) as? RecommendedMeetingCollectionViewCell ?? RecommendedMeetingCollectionViewCell()
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RecommendedMeetingHeaderView.identifier, for: indexPath) as? RecommendedMeetingHeaderView ?? RecommendedMeetingHeaderView()
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 7 * 5) / 4, height: (collectionView.frame.width - 7 * 5) / 4)
    }
}

extension HomeViewController: RecommendedMeetingCollectionViewCellDelegate {
    func didTappedRegisterInterestView() {
        let vc = RegisterInterestViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
