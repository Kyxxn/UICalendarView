//
//  SelectRangeFSCalnderViewController.swift
//  UICalendarViewStudy
//
//  Created by 박효준 on 8/24/24.
//

import FSCalendar
import SnapKit
import Then
import UIKit

class SelectedDateViewController: UIViewController {
    private var firstDate: Date?
    private var lastDate: Date?
    private var datesRange: [Date] = []
    
	let calendarView = FSCalendar().then {
		$0.scrollDirection = .horizontal
		$0.allowsMultipleSelection = true
        $0.register(SelectDatesCustomCalendarCell.self, forCellReuseIdentifier: "SelectDatesCustomCalendarCell")

        $0.appearance.titleFont = .boldSystemFont(ofSize: 18)
        $0.appearance.headerTitleFont = .boldSystemFont(ofSize: 20)
        
        $0.today = nil
        $0.appearance.selectionColor = .clear
        $0.appearance.caseOptions = .weekdayUsesSingleUpperCase
        
        $0.appearance.titleDefaultColor = .black
        $0.appearance.headerTitleColor = .black
        $0.appearance.weekdayTextColor = .black
        $0.appearance.titleSelectionColor = .white
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .gray

		setCalendar()
	}

	func setCalendar() {
        calendarView.delegate = self
        calendarView.dataSource = self
        
        view.addSubview(calendarView)
        calendarView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.width.equalTo(view).offset(-20) // 캘린더의 너비를 부모 뷰에 맞추고 좌우 마진 10씩 추가
            make.height.equalTo(400) // 캘린더의 높이를 명시적으로 설정
        }
	}
}

extension SelectedDateViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if firstDate == nil {
            firstDate = date
            datesRange = [firstDate!]
            
            calendar.reloadData()
            return
        }
        
        if firstDate != nil && lastDate == nil {
            if date < firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                datesRange = [firstDate!]
                
                calendar.reloadData()
                return
            } else {
                var range: [Date] = []
                
                var currentDate = firstDate!
                while currentDate <= date {
                    range.append(currentDate)
                    currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
                }
                
                for day in range {
                    calendar.select(day)
                }
                
                lastDate = range.last
                datesRange = range
                
                calendar.reloadData()
                return
            }
        }
        
        if firstDate != nil && lastDate != nil {
            for day in calendar.selectedDates {
                calendar.deselect(day)
            }
            
            lastDate = nil
            firstDate = date
            calendar.select(date)
            datesRange = [firstDate!]
            
            calendar.reloadData()
            return
        }
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let arr = datesRange
        if !arr.isEmpty {
            for day in arr {
                calendar.deselect(day)
            }
        }
        
        firstDate = nil
        lastDate = nil
        datesRange = []
        
        calendar.reloadData()
    }
}

extension SelectedDateViewController: FSCalendarDataSource {
    func typeOfDate(_ date: Date) -> SelectedDateType {
        let arr = datesRange
        
        if !arr.contains(date) {
            return .notSelected
        } else {
            if arr.count == 1 && date == firstDate { return .singleDate }
            
            if date == firstDate { return .firstDate }
            if date == lastDate { return .lastDate }
            
            else { return .middleDate }
        }
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        guard let cell = calendar.dequeueReusableCell(withIdentifier: "SelectDatesCustomCalendarCell", for: date, at: position) as? SelectDatesCustomCalendarCell else { return FSCalendarCell() }

        cell.updateBackImage(typeOfDate(date))
        return cell
    }
}
