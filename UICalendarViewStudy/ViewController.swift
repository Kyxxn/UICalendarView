import UIKit
import SnapKit
import Then

class ViewController: UIViewController {

    let calendarView = UICalendarView().then {
        $0.backgroundColor = .systemGray
        $0.tintColor = .red
        $0.layer.cornerRadius = 50
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setCalendarView()
        setSelectionBehavior()
    }
    
    func setCalendarView() {
        view.addSubview(calendarView)
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.snp.makeConstraints {
            $0.centerX.equalTo(view)
            $0.centerY.equalTo(view)
        }
    }
    
    func setSelectionBehavior() {
        let multiSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = multiSelection
    }
}

// MARK: 하나만 선택했을 때 어떤 동작 ?
extension ViewController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        if let date = dateComponents?.date {
            let formattedDate = formatDate(date)
            print("선택된 날짜: \(formattedDate)")
        }
    }
}

// MARK: 날짜만 뽑아내기
extension ViewController {
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: date)
    }
}
