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
        
        //countDataを取得して、出社人数・在宅人数から出社率を表示する。
        var countData = CountData()
        var percentage: Int = 0
        var percentageDouble: Double = 0.0
        
        //表示年月日取得
        let monthGetter = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.year], from: self.calendar.currentPage)
        let currentYear = monthGetter.year
        let currentMonth = monthGetter.month
        
        let calendar2 = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.year = currentYear
        components.month = currentMonth
         
        let countRef = Firestore.firestore().collection(Const.countPath)
        
        for dateNum in Calendar.current.range(of: Calendar.Component.day, in: Calendar.Component.month, for: self.calendar.currentPage)! {
            //表示月のX日目の日付変数を作成し、firebaseを検索
            components.day = dateNum
            let date = calendar2.date(from: components)!
            
            countRef.whereField("date", isEqualTo: date)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: " + error.localizedDescription)
                    } else if querySnapshot?.documents != nil && !querySnapshot!.documents.isEmpty {
                        countData = CountData(document: querySnapshot!.documents[0])
                        let companyCountDouble: Double = Double(countData.companyCount!)
                        let homeCountDouble: Double = Double(countData.homeCount!)
                        percentageDouble = homeCountDouble / (companyCountDouble + homeCountDouble) * 100
                        percentage = Int(percentageDouble)
                        self.percentageArray.append(percentage)
                    }
                    self.calendar.reloadData()
                }
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
        let monthGetter = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.year], from: self.calendar.currentPage)
        let currentMonth = monthGetter.month
        
        if Calendar.current.component(.month, from: date) == currentMonth {
            let dateNum = Calendar.current.component(.day, from: date)
            let percentage = percentageArray[dateNum - 1]
            
            return "\(percentage)" + "%"
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
