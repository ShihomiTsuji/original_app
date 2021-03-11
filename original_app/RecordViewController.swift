//
//  RecordViewController.swift
//  original_app
//
//  Created by 辻志保美 on 2021/02/20.
//

import UIKit
import Firebase

class RecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //カスタムセルを登録する
        let nib = UINib(nibName: "RecordTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "RecordCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //決定ボタンの設定
        commitButton.layer.backgroundColor = CGColor(red: 0.96, green: 0.51, blue: 0.40, alpha: 1.0)
        commitButton.layer.cornerRadius = 5
        
        commitButton.layer.shadowColor = UIColor.gray.cgColor
        commitButton.layer.shadowOpacity = 1 //影の色の透明度
        commitButton.layer.shadowRadius = 3 //影のぼかし
        commitButton.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as! RecordTableViewCell
        
        //本日日付を取得し、本日以前の6日間で実績が入力されていない日付を取得し、TableViewに表示
        let today: Date = Date()
        
        let num = -1 * indexPath.row
        let indexDate: Date = Calendar.current.date(byAdding: .day, value: num, to: today)!
        
        var plan: PlanData = PlanData()
        plan.id = ""
        plan.date = indexDate
        plan.attendance = ""
        plan.startTime = indexDate
        plan.endTime = indexDate
        plan.attendReason = ""
                
        let planRef = Firestore.firestore().collection(Const.userPath).document("\(Auth.auth().currentUser?.uid)").collection("items")
            
        planRef.whereField("date", isEqualTo: indexDate)
            .getDocuments {(querySnapshot, error) in
                if let error = error {
                    fatalError("\(error)")
                } else if querySnapshot?.documents != nil && !querySnapshot!.documents.isEmpty {
                    plan = PlanData(document: querySnapshot!.documents[0])
                }
            }
        
        
        cell.setData(plan)
        return cell
    }
    
    //決定ボタン押下時のメソッド

    @IBAction func handleRecordButton(_ sender: Any) {
        for i in 0...5{
            //セルを取得してデータを格納
            let indexPath = IndexPath(row: i, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath) as! RecordTableViewCell
            let planData = cell.getPlanData()
            
            //FireStoreに投稿データを保存する
            let name = Auth.auth().currentUser?.displayName
            let planDic = [
                "name": name!,
                "date": planData.date!,
                "attendance": planData.attendance!,
                "startTime": planData.startTime!,
                "endTime": planData.endTime!,
                "attendReason": planData.attendReason!,
                "healthStatus": planData.healthStatus!
            ] as [String : Any]
            
            //予定データの保存場所
            let uid = Auth.auth().currentUser?.uid
            let planRef = Firestore.firestore().collection(Const.userPath).document(uid!).collection("items").document()
            planRef.setData(planDic)
        }
    }
    
    //Firestoreでリモートで通知を飛ばす方法
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
