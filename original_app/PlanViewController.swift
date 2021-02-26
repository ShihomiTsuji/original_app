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
    
    var selectDate: Date!
    
    //予定データを格納する配列
    //var planArray: [PlanData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        //カスタムセルを登録する
        let nib = UINib(nibName: "PlanTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    /*override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            // 自分が登録した予定データを取得
            let planRef = Firestore.firestore().collection(Const.userPath).document("\(Auth.auth().currentUser?.displayName)").collection("items")
            planRef.whereField("date", isGreaterThanOrEqualTo: selectDate!)
                   .whereField("dare", isLessThanOrEqualTo: selectDate!)
                   .getDocuments {  (snaps, error) in
                if let error = error {
                    fatalError("\(error)")
                }
                self.planArray = snaps!.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let planData = PlanData(document: document)
                    return planData
                }
            }
        }
    }*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        14
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 新規登録用データの作成
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PlanTableViewCell
                    
        var plan: PlanData = PlanData()
        let indexDate = Calendar.current.date(byAdding: .day, value: indexPath.row, to: selectDate!)!
        plan.id = ""
        plan.date = indexDate
        plan.attendance = ""
        plan.startTime = indexDate
        plan.endTime = indexDate
        plan.attendReason = ""
        
        // 自分が登録した予定データを取得
        /*let planRef = Firestore.firestore().collection(Const.userPath).document("\(Auth.auth().currentUser?.uid)").collection("items")
        planRef.whereField("date", isEqualTo: indexDate)
               .getDocuments { (querySnapshot, error) in
            if let error = error {
                fatalError("\(error)")
            } else if querySnapshot?.documents != nil {
                plan = PlanData(document: querySnapshot!.documents[0])
            }
        }
        */
        
        cell.setPlanData(plan)
        return cell
    }
    
    //決定ボタン押下時のメソッド
    @IBAction func handleRecordButton(_ sender: Any) {
        for i in 0...13 {
            //セルを取得してデータを格納
            let indexPath = IndexPath(row: i, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath) as! PlanTableViewCell
            let planData = cell.getPlanData()
            
            //FireStoreに投稿データを保存する
            let planDic = [
                //"name": name!,
                "date": planData.date!,
                "attendance": planData.attendance!,
                "startTime": planData.startTime!,
                "endTime": planData.endTime!,
                "attendReason": planData.attendReason!
            ] as [String : Any]
            
            //予定データの保存場所
            let name = Auth.auth().currentUser?.displayName
            let planRef = Firestore.firestore().collection(Const.userPath).document(name!).collection("items").document()
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
