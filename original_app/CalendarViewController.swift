//
//  CalendarViewController.swift
//  original_app
//
//  Created by 辻志保美 on 2021/02/11.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    @IBOutlet weak var calendar: FSCalendar!

    var nextButton: UIButton!
    var backButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
        
        //翌月に移動ボタンを配置
        let calendarFrame = calendar.frame
        nextButton = UIButton(frame: CGRect(x: calendarFrame.minX+280, y: calendarFrame.minY-10, width: 20, height: 20))
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
        return "aaa"
    }
    
    //詳細表示画面に遷移
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let detailViewController = storyboard!.instantiateViewController(identifier: "Detail")
        present(detailViewController, animated: true)
    
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
