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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
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
        let planRef = Firestore.firestore().collection(Const.userPath).document("\(Auth.auth().currentUser?.uid)").collection("items")
        planRef.whereField("date", isEqualTo: indexDate)
               .getDocuments { (querySnapshot, error) in
            if let error = error {
                fatalError("\(error)")
            } else if querySnapshot?.documents != nil && !querySnapshot!.documents.isEmpty {
                plan = PlanData(document: querySnapshot!.documents[0])
            }
        }
        
        cell.setPlanData(plan)
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
                "date": planData.date!,
                "attendance": planData.attendance!,
                "startTime": planData.startTime!,
                "endTime": planData.endTime!,
                "attendReason": planData.attendReason!,
                "healthStatus": planData.healthStatus!
            ] as [String : Any]
            
            //予定データの保存場所
            let uid = Auth.auth().currentUser?.uid
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
