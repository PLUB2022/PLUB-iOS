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
  private(set) var plubbingID: Int
  private(set) var cursorID: Int?
  private let pagingManager = PagingManager<Schedule>(threshold: 700)
  
  // Input
  let offsetObserver: AnyObserver<(collectionViewHeight: CGFloat, offset: CGFloat)>
  
  // Output
  let scheduleList: Driver<[MeetingScheduleData]>
  
  private let scheduleListRelay = BehaviorRelay<[MeetingScheduleData]>(value: [])
  let bottomCellSubject     = PublishSubject<(collectionViewHeight: CGFloat, offset: CGFloat)>()
  
  init(plubbingID: Int) {
    self.plubbingID = plubbingID
    scheduleList = scheduleListRelay.asDriver()

    offsetObserver = bottomCellSubject.asObserver()
    
    pagingSetup(plubbingID: plubbingID, offsetObservable: bottomCellSubject.asObservable())
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
  
  func fetchScheduleList() {
    pagingManager.refreshPagingData()
     pagingManager.fetchNextPage {  _ in
       ScheduleService.shared
         .inquireScheduleList(
          plubbingID: self.plubbingID,
          cursorID: 0
         )
        .map { data -> (content: [Schedule], nextCursorID: Int, isLast: Bool) in
          return (content: data.scheduleList.schedules, nextCursorID: data.scheduleList.schedules.last?.scheduleID ?? 0, isLast: data.scheduleList.isLast)
        }
    }
     .subscribe(with: self) { owner, content in
       owner.handleScheduleList(data: content, isFirst: true)
     }
     .disposed(by: disposeBag)
  }
  
  private func pagingSetup(
    plubbingID: Int,
    offsetObservable: Observable<(collectionViewHeight: CGFloat, offset: CGFloat)>
  ) {
    offsetObservable
      .filter { [weak self] in // pagingManager에게 fetching 가능한지 요청
        guard let self else { return false }
        return self.pagingManager.shouldFetchNextPage(totalHeight: $0, offset: $1)
      }
      .flatMap { [weak self] _ -> Observable<[Schedule]> in
        guard let self else { return .empty() }
        return self.pagingManager.fetchNextPage { cursorID in
          ScheduleService.shared
            .inquireScheduleList(
              plubbingID: plubbingID,
              cursorID: cursorID
            )
            .map { data -> (content: [Schedule], nextCursorID: Int, isLast: Bool) in
              return (content: data.scheduleList.schedules, nextCursorID: data.scheduleList.schedules.last?.scheduleID ?? 0, isLast: data.scheduleList.isLast)
            }
        }
      }
      .subscribe(with: self) { owner, content in
        owner.handleScheduleList(data: content)
      }
      .disposed(by: disposeBag)
  }
  
  private func handleScheduleList(data: [Schedule], isFirst: Bool = false) {
    
    var oldData = isFirst ? [] : scheduleListRelay.value
    
    data.forEach { schedule in
      let dateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy-M-dd"
      }
      
      let date = dateFormatter
        .date(from: schedule.startDay) ?? Date()
      let dateArr = dateFormatter
        .string(from: date)
        .components(separatedBy: "-")
      
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
                  participants: schedule.participantList?.participants ?? [],
                  indexType: .first,
                  isPasted: (date.compare(Date()) == .orderedAscending) ? true : false,
                  calendarID: schedule.scheduleID
              )
            ]
          )
        )
      } else { // 기존 섹션에 추가
        for (index, data) in oldData.enumerated() {
          if(data.header == year) {
            oldData[index].items.append(
              ScheduleTableViewCellModel(
                month: month,
                day: day,
                time: "\(setupTime(schedule.startTime)) - \(setupTime(schedule.endTime))",
                name: schedule.title,
                location: schedule.placeName,
                participants: schedule.participantList?.participants ?? [],
                indexType: .middle,
                isPasted: (date.compare(Date()) == .orderedAscending) ? true : false,
                calendarID: schedule.scheduleID
              )
            )
            break
          }
        }
      }
    }
    
    oldData.enumerated().forEach { (index, data) in
      let firstIndex = 0
      var firstItem = data.items[firstIndex]
      
      let lastIndex = data.items.count - 1
      var lastItem = data.items[lastIndex]
      
      if data.items.count == 1 {
        // 섹션의 처음이자 마지막 셀이면 indexType firstAndLast로 변경
        firstItem.indexType = .firstAndLast
      } else {
        // 섹션의 첫번째 셀이면 indexType first로 변경
        firstItem.indexType = .first
        // 섹션의 마지막 셀이면 indexType last로 변경
        lastItem.indexType = .last
        
        oldData[index].items[lastIndex] = lastItem
      }
      
      oldData[index].items[firstIndex] = firstItem
    }
    
    scheduleListRelay.accept(oldData)
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
  
  func getCellScheduleID(_ indexPath: IndexPath) -> Int? {
    let data = scheduleListRelay.value
    guard let section = data[safe: indexPath.section],
          let row = section.items[safe: indexPath.row] else { return nil}
    return row.calendarID
  }
}

