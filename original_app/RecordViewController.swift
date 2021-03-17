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
    @IBOutlet weak var backButton: UIButton!
    
    let uid = Auth.auth().currentUser?.uid
    
    //firebaseから取得したデータ格納用の配列
    var tempPlanArray:[PlanData] = []
    
    var arrayCount = 0
    var updateArrayCount = 0
    
    //予定データを格納する配列
    var planArray: [PlanData] = []
    var planIdArray: [String] = []
    var countArray: [CountData] = []
    var countIdArray: [String] = []
    
    //firestoreのデータ取得が実施済みか確認用の変数
    var loadedIndex:Int = 0
    var countLoadedIndex: Int = 0
    
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
        arrayCount = 0
        
        let startDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let endDate = Date()
     
        // 自分が登録した予定データを取得
        let planRef = Firestore.firestore().collection(Const.userPath).document(uid!).collection("items").order(by: "date", descending: false)
        planRef.whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)
            .getDocuments() { (querySnapshot, error) in
                if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            } else if querySnapshot?.documents != nil && !querySnapshot!.documents.isEmpty {
                //planDataを配列に格納
                self.tempPlanArray = querySnapshot!.documents.map { document in
                print("DEBUG_PRINT: document取得 \(document.documentID)")
                let planData = PlanData(document: document)
                self.loadedIndex += 1
                return planData
                }
                //documentIdを配列に格納
                self.planIdArray = querySnapshot!.documents.map { document in
                    return document.documentID
                }
            }
            self.tableView.reloadData()
        }
        
        //countData更新用に既存のcountDataを取得
        let countRef = Firestore.firestore().collection(Const.countPath)
        
        countRef.whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    fatalError("\(error)")
                } else if querySnapshot?.documents != nil && !querySnapshot!.documents.isEmpty {
                    self.countArray = querySnapshot!.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let countData = CountData(document: document)
                    self.countLoadedIndex += 1
                    return countData
                }
                //documentIdを配列に格納
                self.countIdArray = querySnapshot!.documents.map { document in
                    return document.documentID
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 新規登録用データの作成
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as! RecordTableViewCell
        let plan: PlanData = PlanData()
        let num = -5 + indexPath.row
        let date = Calendar.current.date(byAdding: .day, value: num, to: Date())!
        
        if loadedIndex > 0 {
            if arrayCount < tempPlanArray.count {
                //日付をDate(）でとると時間がずれるので、日にちだけで比較
                let formatter = DateFormatter()
                formatter.dateStyle = .long
                formatter.timeStyle = .none
                let planDate = Calendar.current.date(byAdding: .day, value: -1, to: tempPlanArray[arrayCount].date!)!
                let planDateStr = formatter.string(from: planDate)
                let dateStr = formatter.string(from: date)
                if planDateStr == dateStr {
                    cell.setData(tempPlanArray[arrayCount])
                    arrayCount += 1
                } else {
                    plan.date = date
                    cell.setData(plan)
                }
            }
        } else {
            plan.date = date
            plan.startTime = date
            plan.endTime = date
            cell.setData(plan)
        }
        return cell
    }
    
    //決定ボタン押下時のメソッド
    @IBAction func handleRecordButton(_ sender: Any) {
        for i in 0...5{
            
            //セルを取得してデータを格納
            let indexPath = IndexPath(row: i, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath) as! RecordTableViewCell
            let planData = cell.getData()
            
            //FireStoreに投稿データを保存する
            let name = Auth.auth().currentUser?.displayName
            let planDic = [
                "name": name!,
                "date": Timestamp(date: planData.date!),
                "attendance": planData.attendance!,
                "startTime": planData.startTime!,
                "endTime": planData.endTime!,
                "attendReason": planData.attendReason!,
                "healthStatus": planData.healthStatus!
            ] as [String : Any]
            
            //予定データの保存場所
            let planRef = Firestore.firestore().collection(Const.userPath).document(uid!).collection("items").document()
            
            //カウントデータ用の情報を取得
            var companyNum = 0
            var homeNum = 0
            
            if planData.attendance! == "出社" {
                companyNum = 1
            } else if planData.attendance! == "在宅" {
                homeNum = 1
            }
            
            let count = CountData()
            let countDic = [
                "date": planData.date!,
                "companyCount": count.companyCount! + companyNum,
                "homeCount": count.homeCount! + homeNum
            ] as [String : Any]
            
            let countRef = Firestore.firestore().collection(Const.countPath).document()
            
            //日毎に既存データがあれば更新、なければ新規登録
            if updateArrayCount < tempPlanArray.count {
                let num = -5 + indexPath.row
                let date = Calendar.current.date(byAdding: .day, value: num, to: Date())!
                
                let formatter = DateFormatter()
                formatter.dateStyle = .long
                formatter.timeStyle = .none
                let planDateStr = formatter.string(from: tempPlanArray[updateArrayCount].date!)
                let dateStr = formatter.string(from: date)
                if planDateStr == dateStr {
                    //planData更新
                    let id = planIdArray[updateArrayCount]
                    let planUpdateRef = Firestore.firestore().collection(Const.userPath).document(uid!).collection("items").document(id)
                    planUpdateRef.updateData(planDic) { error in
                        if let error = error {
                            print("UPDATE_ERROR: \(error)")
                        } else {
                            print("Document Updated: \(id)")
                        }
                    }
                    
                    //countDataは自分の過去分の登録内容と異なれば更新
                    let countId = countIdArray[updateArrayCount]
                    let countUpdateRef = Firestore.firestore().collection(Const.countPath).document(countId)
                    let originalAttendance = tempPlanArray[updateArrayCount].attendance!
                    
                    if originalAttendance != planDic["attendance"] as! String {
                        if originalAttendance == "出社" {
                            //出社→在宅になった場合はcompanyCountを１減らし、homeCountを１増やす
                            countUpdateRef.updateData(["companyCount": FieldValue.increment(Int64(-1))])
                            countUpdateRef.updateData(["homeCount": FieldValue.increment(Int64(1))])
                        } else if originalAttendance == "在宅" {
                            //在宅→出社になった場合はcompanyCountを１増やし、homeCountを１減らす
                            countUpdateRef.updateData(["companyCount": FieldValue.increment(Int64(1))])
                            countUpdateRef.updateData(["homeCount": FieldValue.increment(Int64(-1))])
                        }
                        
                    }
                    
                    updateArrayCount += 1
                }else {
                    planRef.setData(planDic)
                    countRef.setData(countDic)
                }
            } else {
                planRef.setData(planDic)
                countRef.setData(countDic)
            }
            
            let userRef = Firestore.firestore().collection(Const.userPath).document(uid!)
            userRef.setData(["userName": name!])
        }
        //保存後画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backTapped(_ sender: Any) {
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

