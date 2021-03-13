//
//  CalendarViewController.swift
//  original_app
//
//  Created by 辻志保美 on 2021/02/11.
//

import UIKit
import FSCalendar
import Firebase

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    @IBOutlet weak var calendar: FSCalendar!

    var nextButton: UIButton!
    var backButton: UIButton!
    
    //カレンダーのsubtitleに表示する出社割合の配列
    var percentageArray:[Int] = []
    //firebaseから取得したデータ格納用の配列
    var countArray:[CountData] = []
    //firestoreのデータ取得が実施済みか確認用の変数
    var loadedIndex:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
        
        //翌月に移動ボタンを配置
        let calendarFrame = calendar.frame
        nextButton = UIButton(frame: CGRect(x: calendarFrame.maxX-120, y: calendarFrame.minY-10, width: 20, height: 20))
        self.nextButton.setTitle("＞", for: .normal)
        self.nextButton.setTitleColor(UIColor.red, for: .normal)
        self.view.addSubview(nextButton)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        self.view.bringSubviewToFront(nextButton)
        
        //前月に移動ボタンを配置
        backButton = UIButton(frame: CGRect(x: calendarFrame.minX+10, y: calendarFrame.minY-10, width: 20, height: 20))
        self.backButton.setTitle("＜", for: .normal)
        self.backButton.setTitleColor(UIColor.red, for: .normal)
        self.view.addSubview(backButton)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        self.view.bringSubviewToFront(backButton)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Firebaseから出社・在宅カウントデータを取得
        //表示している年月日取得
        let monthGetter = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.year], from: self.calendar.currentPage)
        let currentYear = monthGetter.year
        let currentMonth = monthGetter.month
        
        var startComponents = DateComponents()
        var endComponents = DateComponents()
        startComponents.year = currentYear
        startComponents.month = currentMonth
        startComponents.day = 1
        endComponents.year = currentYear
        endComponents.month = currentMonth! + 1
        // 日数を0にすることで、前の月の最後の日になる
        startComponents.day = 0
        //日付に変換
        let calendar2 = Calendar(identifier: .gregorian)
        let startDate = calendar2.date(from: startComponents)!
        let endDate = calendar2.date(from: endComponents)!
            
        let countRef = Firestore.firestore().collection(Const.countPath)
                
        //表示月のcountDataをfirebaseから取得
        countRef.whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                } else if querySnapshot?.documents != nil && !querySnapshot!.documents.isEmpty {
                    self.countArray = querySnapshot!.documents.map {document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let countData = CountData(document: document)
                    self.loadedIndex += 1
                    return countData
                    }
                }
            self.calendar.reloadData()
            }
    }
    
    //前月・翌月ボタン押下時の処理
    @objc func nextButtonTapped(_sender: UIButton){
        calendar.setCurrentPage(getNextMonth(date: calendar.currentPage), animated: true)
    }
    
    @objc func backButtonTapped(_sender: UIButton){
        calendar.setCurrentPage(getLastMonth(date: calendar.currentPage), animated: true)
    }
    
    func getNextMonth(date:Date)->Date {
        return  Calendar.current.date(byAdding: .month, value: 1, to:date)!
    }
    
    func getLastMonth(date:Date)->Date {
        return  Calendar.current.date(byAdding: .month, value: -1, to:date)!
    }
    
    //各日付に出社率を表示
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        //表示している年月日取得
        let monthGetter = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.year], from: self.calendar.currentPage)
        let currentYear = monthGetter.year
        let currentMonth = monthGetter.month
        //出社割合表示用の配列percentageArrayを更新
        var components = DateComponents()
        components.year = currentYear
        components.month = currentMonth
        
        let calendar2 = Calendar(identifier: .gregorian)
        var arrayCount = 0
        let cal = Calendar.current.range(of: Calendar.Component.day, in: Calendar.Component.month, for: self.calendar.currentPage)!
        
        if loadedIndex > 0 {
            for dateNum in cal {
                components.day = dateNum
                let date = calendar2.date(from: components)!
                
                if countArray[arrayCount].date == date {
                    //取得したcountDataから、出社人数・在宅人数から出社率を計算
                    let countData = countArray[arrayCount]
                    var percentage: Int = 0
                    var percentageDouble: Double = 0.0
                    
                    let companyCountDouble: Double = Double(countData.companyCount!)
                    let homeCountDouble: Double = Double(countData.homeCount!)
                    percentageDouble = companyCountDouble / (companyCountDouble + homeCountDouble) * 100
                    percentage = Int(percentageDouble)
                    self.percentageArray.append(percentage)
                    
                    arrayCount += 1
                } else {
                    self.percentageArray.append(0)
                }
            }
            
            //表示月の日付のsubtitleにはpercentageを表示
            if Calendar.current.component(.month, from: date) == currentMonth {
                let dateNum = Calendar.current.component(.day, from: date)
                let percentage = percentageArray[dateNum - 1]
                
                return "\(percentage)" + "%"
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    
    //詳細表示画面に遷移
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let detailViewController = storyboard!.instantiateViewController(withIdentifier: "Detail") as! DetailViewController
        detailViewController.selectDate = date
        self.present(detailViewController, animated: true)
    
    }
    



    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
