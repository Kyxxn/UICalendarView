import UIKit
import SnapKit
import Then

class ViewController: UIViewController {
    
    let calendarView = UICalendarView().then {
        $0.locale = Locale(identifier: "ko_KR")
        $0.tintColor = .red
        $0.wantsDateDecorations = true // 데코 꾸미기 (기본값 true)
    }
    
    let myButton = UIButton(type: .system).then {
        $0.isEnabled = false
        $0.setTitle("완료", for: .disabled)
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
    
    func setSelectionBehavior() {
        let singleSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = singleSelection
    }
}

// MARK: UICalendarViewDelegate 프로토콜 메소드
// 특정 날짜에 대해 데코레이션 할 때 사용, 일정 불러오기 할 때 쓰면 될듯
extension ViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        if let day = dateComponents.day, day == 25 {
            return .image(UIImage(systemName: "gift.fill"), color: .systemRed, size: .small)
        }
        return nil
    }
}

// MARK: 하나만 선택했을 때, 어떤 동작 할래??
// 여러 개 선택하고 싶으면 MultiDateDelegate
extension ViewController: UICalendarSelectionSingleDateDelegate {
    private func enableButton() {
        myButton.isEnabled = true
        myButton.backgroundColor = .systemOrange
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        enableButton()
        if let date = dateComponents?.date {
            selectedDate = date
            let formattedDate = formatDate(date)
            print("선택된 날짜: \(formattedDate)")
        }
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
