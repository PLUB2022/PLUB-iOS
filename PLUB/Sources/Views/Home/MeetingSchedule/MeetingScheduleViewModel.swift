//
//  MeetingScheduleViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/25.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

struct MeetingScheduleData {
    var header: String?
    var items: [Item]
}

extension MeetingScheduleData: SectionModelType {
  typealias Item = ScheduleTableViewCellModel
  
  init(original: MeetingScheduleData, items: [Item]) {
   self = original
   self.items = items
 }
}

final class MeetingScheduleViewModel {
  var datas = BehaviorRelay<[MeetingScheduleData]>(value: [])
  init() {
    let imageURL = "https://img.insight.co.kr/static/2019/04/19/700/2j6xsl93c2fc7c5td0bm.jpg"
    let imageList = [String](repeating: imageURL, count: 10)
    let model = ScheduleTableViewCellModel(
      day: "9월 15일",
      time: "오후 5:30 - 오후 8:00",
      name: "프로젝트 기획",
      location: "투썸 플레이스 강남역점",
      participants: imageList,
      indexType: .middle,
      isPasted: false
    )
    var modelList = [ScheduleTableViewCellModel](repeating: model, count: 10)
    
    
    modelList[0] = ScheduleTableViewCellModel(
      day: "9월 15일",
      time: "오후 5:30 - 오후 8:00",
      name: "프로젝트 기획",
      location: "투썸 플레이스 강남역점",
      participants: imageList,
      indexType: .first,
      isPasted: false
    )
    modelList[modelList.count - 1] = ScheduleTableViewCellModel(
      day: "9월 15일",
      time: "오후 5:30 - 오후 8:00",
      name: "프로젝트 기획",
      location: "투썸 플레이스 강남역점",
      participants: imageList,
      indexType: .last,
      isPasted: true
    )
    
    datas = BehaviorRelay<[MeetingScheduleData]>(value: [
      MeetingScheduleData(header:"섹션 1 header", items: modelList),
      MeetingScheduleData(header:"섹션 2 header", items: modelList),
      MeetingScheduleData(items: modelList)
    ])
  }
  
  func dataSource() -> RxTableViewSectionedReloadDataSource<MeetingScheduleData> {
    
      // Cell
      let dataSource = RxTableViewSectionedReloadDataSource<MeetingScheduleData>(
        configureCell: { dataSource, tableView, indexPath, item in
          
          guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell", for: indexPath) as? ScheduleTableViewCell else {return UITableViewCell()}
          cell.setupData(with: item)
          
          return cell
          
      // Header
      }, titleForHeaderInSection: { dataSource, index in

        return dataSource.sectionModels[index].header
      })
    
      return dataSource
  }
}
