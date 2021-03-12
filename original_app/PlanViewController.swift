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
    @IBOutlet weak var commitButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var selectDate: Date!
    
    let uid = Auth.auth().currentUser?.uid
    
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
        
        //決定ボタンの設定
        commitButton.layer.backgroundColor = CGColor(red: 0.96, green: 0.51, blue: 0.40, alpha: 1.0)
        commitButton.layer.cornerRadius = 7
        
        commitButton.layer.shadowColor = UIColor.gray.cgColor
        commitButton.layer.shadowOpacity = 1 //影の色の透明度
        commitButton.layer.shadowRadius = 3 //影のぼかし
        commitButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        //戻るボタンの設定
        backButton.layer.backgroundColor = UIColor.white.cgColor
        backButton.layer.borderWidth = 2
        backButton.layer.cornerRadius = 6
        backButton.layer.borderColor = CGColor(red: 0.96, green: 0.51, blue: 0.40, alpha: 1.0)
        
        backButton.layer.shadowColor = UIColor.gray.cgColor
        backButton.layer.shadowOpacity = 1 //影の色の透明度
        backButton.layer.shadowRadius = 3 //影のぼかし
        backButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var plan: PlanData = PlanData()
        let indexDate = Calendar.current.date(byAdding: .day, value: 0, to: selectDate!)!
        let timestampDate = Timestamp(date: indexDate)
        /*plan.date = indexDate
        plan.startTime = indexDate
        plan.endTime = indexDate*/
        
        // 自分が登録した予定データを取得
        let planRef = Firestore.firestore().collection(Const.userPath).document(uid!).collection("items")
        planRef.whereField("date", isEqualTo: timestampDate)
               .getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            } else if querySnapshot?.documents != nil && !querySnapshot!.documents.isEmpty {
                //取得した予定データをplanに代入
                let dateTimestamp:Timestamp = querySnapshot?.documents[0].get("date") as! Timestamp
                print("timestamp: \(dateTimestamp)")
                let dateValue = dateTimestamp.dateValue()
                print("date: \(dateValue)")
                plan = PlanData(document: querySnapshot!.documents[0])
                self.planArray.append(plan)
            } else {
                self.planArray.append(plan)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //7
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 新規登録用データの作成
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PlanTableViewCell
        print(planArray.count)
        
        cell.setPlanData(planArray[indexPath.row])
        
        return cell
    }
    
    //決定ボタン押下時のメソッド
    @IBAction func handleRecordButton(_ sender: Any) {
        for i in 0...6{
            //セルを取得してデータを格納
            let indexPath = IndexPath(row: i, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath) as! PlanTableViewCell
            let planData = cell.getPlanData()
            
            //FireStoreに投稿データを保存する
            let name = Auth.auth().currentUser?.displayName
            let planDic = [
                "name": name!,
                "date": Timestamp(date: planData.date!), //timestamp型に
                "attendance": planData.attendance!,
                "startTime": planData.startTime!,
                "endTime": planData.endTime!,
                "attendReason": planData.attendReason!,
                "healthStatus": planData.healthStatus!
            ] as [String : Any]
            
            //予定データの保存場所
            let userRef = Firestore.firestore().collection(Const.userPath).document(uid!)
            userRef.setData(["userName": name!])
            let planRef = Firestore.firestore().collection(Const.userPath).document(uid!).collection("items").document()
            planRef.setData(planDic)
            
            //カウントデータ用の情報を取得
            var companyNum = 0
            var homeNum = 0
            
            if planData.attendance! == "出社" {
                companyNum = 1
            } else if planData.attendance! == "在宅" {
                homeNum = 1
            }
            
            var count = CountData()
            let countDic = [
                "date": planData.date!,
                "companyCount": count.companyCount! + companyNum,
                "homeCount": count.homeCount! + homeNum
            ] as [String : Any]
            
            let countRef = Firestore.firestore().collection(Const.countPath)
            
            countRef.whereField("date", isEqualTo: planData.date!)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        fatalError("\(error)")
                    } else if querySnapshot?.documents != nil && !querySnapshot!.documents.isEmpty {
                        count = CountData(document: querySnapshot!.documents[0])
                        let formatter = DateFormatter()
                        let date = planData.date!
                        formatter.dateFormat = "yyyy/MM/dd"
                        let dateString = formatter.string(from: date)
                        
                        let countSaveRef = Firestore.firestore().collection(Const.countPath).document(dateString)
                        
                        countSaveRef.updateData([
                            "companyCout": count.companyCount! + companyNum,
                            "homeCount": count.homeCount! + homeNum
                        ])
                        
                    } else {
                        let countSaveRef = Firestore.firestore().collection(Const.countPath).document()
                        countSaveRef.setData(countDic)
                    }
                }
            
            //保存後画面を閉じる
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    //戻るボタン押下時
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
