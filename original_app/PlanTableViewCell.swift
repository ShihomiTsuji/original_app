//
//  PlanTableViewCell.swift
//  original_app
//
//  Created by 辻志保美 on 2021/02/15.
//

import UIKit

class PlanTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var reasonTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //PlanDataの内容をセルに表示
    func setPlanData(_ planData: PlanData) {
        //日付の表示
        let formatter = DateFormatter()
        let date = planData.date!
        formatter.dateFormat = "yyyy/MM/dd"
        let dateString = formatter.string(from: date)
        self.dateLabel.text = dateString
        
        if planData.attendance == "出社" {
            self.segmentedControl.selectedSegmentIndex = 1
        }
        
        self.endTimePicker.date = planData.date!
        self.startTimePicker.date = planData.date!
        
        if planData.attendReason != nil {
            self.reasonTextField.text = planData.attendReason!
        }
    }
    
    //cellに入力されている内容を取得
    func getPlanData() -> PlanData {
        //空のplanDataを作成
        let planData = PlanData()
        
        //値を設定
        //dateの値設定
        let formatter = DateFormatter()
        let dateString = dateLabel.text!
        formatter.dateFormat = "yyyy/MM/dd"
        let date = formatter.date(from: dateString)
        planData.date = date
        
        planData.name = "" //ユーザ名を入れる
        
        let segmentIndex = segmentedControl.selectedSegmentIndex
        planData.attendance = segmentedControl.titleForSegment(at: segmentIndex)
        
        planData.startTime = startTimePicker.date
        
        planData.endTime = endTimePicker.date
        
        planData.attendReason = reasonTextField.text
        
        planData.healthStatus = "None"
        
        return planData
    }
    
}
