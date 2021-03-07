//
//  DetailViewController.swift
//  original_app
//
//  Created by 辻志保美 on 2021/02/11.
//

import UIKit
import Firebase

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    var selectDate: Date!
    
    var header = [String]()
    var member = [[PlanData]]()
    var planArray: [PlanData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        header = ["出社", "在宅"]
        
        for _ in 0...1 {
            member.append([])
        }
        
        //for文で全メンバーのデータを取得し、今出社しているメンバーを出社扱いとする。
        let planRef = Firestore.firestore().collection(Const.userPath).document("\(Auth.auth().currentUser?.uid)").collection("items")
        
        //出社しているメンバー
        //member[0] = ["aa", "bb", "cc"]
        planRef.whereField("attendance", isEqualTo: "出社")
               .whereField("date", isEqualTo: selectDate!)
               .getDocuments { (querySnapshot, error) in
            if let error = error {
                fatalError("\(error)")
            } else if querySnapshot?.documents != nil {
                self.planArray = querySnapshot!.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let planData = PlanData(document: document)
                    return planData
                    }
                }
            }
        
        if planArray.count > 0 {
            for i in 0...planArray.count - 1 {
                member[0].append(planArray[i])
            }
        }
        
        //在宅しているメンバー
        //member[1] = ["cc", "dd", "ee"]
        planRef.whereField("attendance", isEqualTo: "在宅")
               .whereField("date", isEqualTo: selectDate!)
               .getDocuments { (querySnapshot, error) in
            if let error = error {
                fatalError("\(error)")
            }
            self.planArray = querySnapshot!.documents.map { document in
            print("DEBUG_PRINT: document取得 \(document.documentID)")
            let planData = PlanData(document: document)
            print("在宅データあり")
            return planData
            }
        }
        
        if planArray.count > 0 {
            for i in 0...planArray.count - 1 {
                member[1].append(planArray[i])
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //プラスボタンの設定
        addButton.imageView?.contentMode = .scaleAspectFit
        addButton.contentHorizontalAlignment = .fill
        addButton.contentVerticalAlignment = .fill
        addButton.tintColor = .white
        
        //戻るボタンの設定
        backButton.layer.borderWidth = 2
        backButton.layer.cornerRadius = 10
        backButton.layer.borderColor = CGColor(red: 0.96, green: 0.51, blue: 0.40, alpha: 1.0)
        
        //日付表示
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let selectDateStr = formatter.string(from: selectDate!)
        print(selectDateStr)
        dateLabel.text = "   " + selectDateStr
    }
    
    //出社・在宅のセクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        return header.count
    }
    
    //各セクションの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return member[section].count
    }
    
    //出社・在宅のセクション名
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return header[section]
    }
    
    //各セクションのセル
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //名前表示
        let nameLabel = cell.viewWithTag(1) as! UILabel
        nameLabel.text = (member[indexPath.section][indexPath.row].name)
        
        //出社時間表示
        let timeLabel = cell.viewWithTag(2) as! UILabel
        let formatter = DateFormatter()
        let startTimeStr = formatter.string(from: member[indexPath.section][indexPath.row].startTime!)
        let endTimeStr = formatter.string(from: member[indexPath.section][indexPath.row].endTime!)
        timeLabel.text = (startTimeStr + "→" + endTimeStr)
        
        //体調表示
        //let healthLabel = cell.viewWithTag(3) as! UILabel
        //if member[indexPath.section][indexPath.row].
        
        return cell
    }
    
    //予定画面に選択した日付を渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let planView = segue.destination as! PlanViewController
        planView.selectDate = self.selectDate
    }
    
    // セクションの背景とテキストの色を変更する
        func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
            // 背景色を変更する
            view.tintColor = UIColor(red: 0.97, green: 0.64, blue: 0.56, alpha: 1.0)

            let header = view as! UITableViewHeaderFooterView
            // テキスト色を変更する
            header.textLabel?.textColor = UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1.0)
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
