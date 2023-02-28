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
  private let disposeBag = DisposeBag()
  private let plubbingID: String
  
  let datas = BehaviorRelay<[MeetingScheduleData]>(value: [])
  
  init(plubbingID: String) {
    self.plubbingID = plubbingID

    fetchScheduleList()
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
  
  private func fetchScheduleList() {
    ScheduleService.shared
      .inquireScheduleList(
        plubbingID: plubbingID
      )
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          guard let data = model.data else { return }
          owner.handleScheduleList(data: data.scheduleList.schedules)
        default: break// TODO: 수빈 - PLUB 에러 Alert 띄우기
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func handleScheduleList(data: [Schedule]) {
    var oldData = datas.value
    
    data.enumerated().forEach { (index, schedule) in
      let date = DateFormatter().then {
        $0.dateFormat = "yyyy-MM-dd"
      }.date(from: schedule.startDay) ?? Date()
      
      let dateArr = schedule.startDay.components(separatedBy: "-")
      let year = dateArr[0]
      let month = dateArr[1]
      let day = dateArr[2]
      
      if (oldData.filter { $0.header == year }.count == 0) { // 섹션 생성
        
        oldData.append(
          MeetingScheduleData(
            header: year,
            items: [
                ScheduleTableViewCellModel(
                  month: month,
                  day: day,
                  time: "\(setupTime(schedule.startTime)) - \(setupTime(schedule.endTime))",
                  name: schedule.title,
                  location: schedule.placeName,
                  participants: (schedule.participantList?.participants.map{
                    $0.profileImage
                  }) ?? [],
                  indexType: .first,
                  isPasted: (date.compare(Date()) == .orderedAscending) ? true : false
              )
            ]
          )
        )
      } else { // 기존 섹션에 추가
        
        oldData.enumerated().forEach { (index, data) in
          if(data.header == year) {
            oldData[index].items.append(
              ScheduleTableViewCellModel(
                month: month,
                day: day,
                time: "\(setupTime(schedule.startTime)) - \(setupTime(schedule.endTime))",
                name: schedule.title,
                location: schedule.placeName,
                participants: (schedule.participantList?.participants.map{
                  $0.profileImage
                }) ?? [],
                indexType: .middle,
                isPasted: (date.compare(Date()) == .orderedAscending) ? true : false
              )
            )
          }
        }
      }
    }
    
    // 섹션의 마지막 셀이면 indexType last로 변경
    oldData.enumerated().forEach { (index, data) in
      let lastIndex = data.items.count - 1
      var lastItem = data.items[lastIndex]
      lastItem.indexType = .last
      oldData[index].items[lastIndex] = lastItem
    }
    
    datas.accept(oldData)
  }

  private func setupTime(_ time: String) -> String {
    let date = DateFormatter().then {
      $0.dateFormat = "hh:mm"
      $0.locale = Locale(identifier: "ko_KR")
    }.date(from: time) ?? Date()
    
    return DateFormatter().then {
      $0.dateFormat = "a h시 m분"
      $0.locale = Locale(identifier: "ko_KR")
    }.string(from: date)
  }
}
