//
//  RecordTableViewCell.swift
//  original_app
//
//  Created by 辻志保美 on 2021/02/11.
//

import UIKit

class RecordTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var healthButton: UIButton!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var reasonTextField: UITextField!
    
    //顔マーク設定用
    let img0 = UIImage(named:"img00")!
    let img1 = UIImage(named:"img1")!
    let img2 = UIImage(named:"img2")!
    var healthStatus: String = "None"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //PlanDataの内容をセルに表示
    func setData(_ planData: PlanData) {
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
        
        //顔マークの表示
        if planData.healthStatus! == "Good" {
            healthButton.setImage(img1, for: .normal)
            healthStatus = "Good"
        } else if planData.healthStatus! == "Bad" {
            healthButton.setImage(img2, for: .normal)
            healthStatus = "Bad"
        } else if planData.healthStatus! == "None" {
            healthButton.setImage(img0, for: .normal)
            healthStatus = "None"
        }
        
    }
    
    //ボタンタップでhealthStatusと顔マークを変更
    @IBAction func buttonTapped(_ sender: Any) {    
        if healthStatus == "Bad" || healthStatus == "None" {
            healthButton.setImage(img1, for: .normal)
            healthStatus = "Good"
        }
        else if healthStatus == "Good" {
            healthButton.setImage(img2, for: .normal)
            healthStatus = "Bad"
        }
    }
    
    //cellに入力されている内容を取得
    func getData() -> PlanData {
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
        
        planData.healthStatus = healthStatus
        
        return planData
    }
}
