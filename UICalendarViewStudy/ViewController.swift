import UIKit
import SnapKit
import Then

class ViewController: UIViewController {
    
    let calendarView = UICalendarView().then {
        $0.locale = Locale(identifier: "ko_KR")
        $0.wantsDateDecorations = true // 데코 꾸미기 (기본값 true)
    }
    
    let responseDays = [1, 5, 15, 22, 25, 30]
    
    let myButton = UIButton(type: .system).then {
        $0.isEnabled = false
        $0.setTitle("취소", for: .disabled)
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(.systemGray, for: .disabled)
        $0.setTitleColor(.white, for: .normal)
        
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 12
    }
    
    var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setCalendarView()
        setButton()
        setSelectionBehavior()
    }
    
    /// 하나만 클릭될 수 있게, 만약 여러 개 선택하고 싶으면 MultiDateDelegate
    func setSelectionBehavior() {
        // UICalendarSelectionSingleDate(delegate: self)
        let selectionDelegate = UICalendarSelectionMultiDate(delegate: self)
        calendarView.selectionBehavior = selectionDelegate
    }
}

// MARK: UICalendarViewDelegate 프로토콜 메소드
extension ViewController: UICalendarViewDelegate {
    /// 해당 월의 캘린더를 불러올 때, 특정 날짜에 데코레이션해줄 수 있음
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        if let day = dateComponents.day, responseDays.contains(day) {
            return .default()
        }
        return nil
    }
    
    /// 캘린더의 월이 바뀌면 동작함, 서버한테 요청하면 될듯
    func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        print(calendarView.visibleDateComponents.year!)
        print(calendarView.visibleDateComponents.month!)
    }
}

// MARK: 하나만 선택했을 때, 어떤 동작 할래??
extension ViewController: UICalendarSelectionSingleDateDelegate {
    
    /// 날짜가 하나 클릭 됐을 때 동작
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        enableButton()
        if let date = dateComponents?.date {
            selectedDate = date
            let formattedDate = formatDate(date)
            print("선택된 날짜: \(formattedDate)")
        }
    }
}

/// multiDateSelection(_:didSelectDate:): 사용자가 날짜를 선택할 때 호출되며, 선택된 날짜에 대한 작업을 처리할 수 있습니다.
/// multiDateSelection(_:didDeselectDate:): 사용자가 날짜를 선택 해제할 때 호출되며, 해제된 날짜에 대한 작업을 처리할 수 있습니다.
/// multiDateSelection(_:canSelectDate:): 특정 날짜가 선택 가능한지 여부를 결정하는 메소드로, 선택을 제한할 수 있습니다.
/// multiDateSelection(_:canDeselectDate:): 특정 날짜가 선택 해제 가능한지 여부를 결정하는 메소드로, 해제를 제한할 수 있습니다.

extension ViewController: UICalendarSelectionMultiDateDelegate {
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didSelectDate dateComponents: DateComponents) {
        if let date = dateComponents.date {
            // 이미 선택된 날짜가 있고, 그 날짜와 동일한 날짜가 다시 클릭되면 해제
            if let selectedDate = selectedDate, selectedDate == date {
                selection.setSelectedDates([], animated: false)
                self.selectedDate = nil
                print("선택 해제된 날짜: \(selectedDate)")
                return
            } else {
                // 다른 날짜를 클릭하면 이전 날짜를 해제하고 새 날짜를 선택
                selection.setSelectedDates([dateComponents], animated: true)
            }
            
            self.selectedDate = date // 선택된 날짜를 저장
            enableButton()
            let formattedDate = formatDate(date)
            print("선택된 날짜: \(formattedDate)")
        }
    }
    
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didDeselectDate dateComponents: DateComponents) {
        print("선택 해제된 날짜: \(dateComponents.date!)")
        disableButton()
    }

}

// MARK: 날짜만 뽑아내기
extension ViewController {
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: date)
    }
}

// MARK: 레이아웃 설정
extension ViewController {
    func setCalendarView() {
        view.addSubview(calendarView)
        
        calendarView.delegate = self
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.snp.makeConstraints {
            $0.centerX.equalTo(view)
            $0.centerY.equalTo(view)
            $0.width.equalTo(view.snp.width).multipliedBy(0.9)
        }
    }
    
    func setButton() {
        view.addSubview(myButton)
        
        myButton.translatesAutoresizingMaskIntoConstraints = false
        myButton.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(20)
            $0.leading.equalTo(view.snp.leading).offset(18)
            $0.trailing.equalTo(view.snp.trailing).offset(-18)
            $0.height.equalTo(56)
        }
    }
}

// MARK: 버튼 활성/비활성 세팅
extension ViewController {
    private func enableButton() {
        myButton.isEnabled = true
        myButton.backgroundColor = .systemOrange
    }
    
    private func disableButton() {
        myButton.isEnabled = false
        myButton.backgroundColor = .systemGray5
    }
}
