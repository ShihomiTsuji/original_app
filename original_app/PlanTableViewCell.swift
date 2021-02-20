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
    
    //PlanDataの内容をセルに表示 　※要修正
    func setPlanData(_ planData: PlanData) {
        //日付の表示
        self.dateLabel.text = "\(planData.date!)"
        
    }
    
    //cellに入力されている内容を取得
    func getPlanData() -> PlanData {
        //空のplanDataを作成
        var planData = PlanData()
        
        //値を設定
        //dateの値設定
        let formatter = DateFormatter()
        let dateString = dateLabel.text!
        formatter.dateFormat = "yyyy/mm/dd"
        let date = formatter.date(from: dateString)
        planData.date = date
        
        planData.name = "" //ユーザ名を入れる
        
        let segmentIndex = segmentedControl.selectedSegmentIndex
        planData.attendance = segmentedControl.titleForSegment(at: segmentIndex)
        
        planData.startTime = startTimePicker.date
        
        planData.endTime = endTimePicker.date
        
        planData.attendReason = reasonTextField.text
        
        return planData
    }
    
}
