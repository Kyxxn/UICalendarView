import UIKit
import SnapKit
import Then

class ViewController: UIViewController {

    let calendarView = UICalendarView().then {
        $0.locale = Locale(identifier: "ko_KR")
    }
    
    let myButton = UIButton(type: .system).then {
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .systemGray
        $0.layer.cornerRadius = 12
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setCalendarView()
        setButton()
        setSelectionBehavior()
    }
    
    func setButton() {
        view.addSubview(myButton)
        
        myButton.translatesAutoresizingMaskIntoConstraints = false
        myButton.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(20)
            $0.leading.equalTo(view.snp.leading).offset(18)
            $0.trailing.equalTo(view.snp.trailing).offset(-18)
        }
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
        let singleSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = singleSelection
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
