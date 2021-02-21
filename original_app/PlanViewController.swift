//
//  PlanViewController.swift
//  original_app
//
//  Created by 辻志保美 on 2021/02/11.
//

import UIKit
import Firebase

class PlanViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    //予定データを格納する配列
    var planArray: [PlanData] = [] 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        //カスタムセルを登録する
        let nib = UINib(nibName: "PlanTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        14
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PlanTableViewCell
        cell.setPlanData(planArray[indexPath.row])

        return cell
    }
    
    //決定ボタン押下時のメソッド
    @IBAction func handleRecordButton(_ sender: Any) {
        for i in 0...13 {
            //セルを取得してデータを格納
            let indexPath = IndexPath(index: i)
            let cell = self.tableView.cellForRow(at: indexPath) as! PlanTableViewCell
            let planData = cell.getPlanData()
            
            //FireStoreに投稿データを保存する
            let planDic = [
                "date": planData.date!,
                "name": planData.name!,
                "attendance": planData.attendance,
                "startTime": planData.startTime,
                "endTime": planData.endTime,
                "attendReason": planData.attendReason
            ] as [String : Any]
            
            //予定データの保存場所
            let planRef = Firestore.firestore().collection(Const.PlanPath).document()
            planRef.setData(planDic)
            
            //保存後画面を閉じる
            dismiss(animated: true, completion: nil)
        }
        
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
