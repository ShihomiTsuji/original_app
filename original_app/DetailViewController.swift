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
    
    let img0 = UIImage(named:"img00")!
    let img1 = UIImage(named:"img1")!
    let img2 = UIImage(named:"img2")!
    
    var selectDate: Date!
    
    //var members = [String]()
    var header = [String]()
    var member = [[PlanData]]()
    var planArray: [PlanData] = []
    var planData: PlanData = PlanData()
    var loadedIndex = 0
    
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
        //データを登録している社員の一覧を取得
        let memberRef = Firestore.firestore().collection(Const.userPath)
        memberRef.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if querySnapshot?.documents != nil && !querySnapshot!.documents.isEmpty  {
                for document in querySnapshot!.documents {
                    let name = document.documentID
                    print(name)
                    //self.members.append(document.documentID)
                    //membersに格納されている社員の選択日の勤務予定を取得し、memberに格納
                    //for userId in members { //userIdがnameになる
                    let planRef = Firestore.firestore().collection(Const.userPath).document("\(name)").collection("items")
                        
                    planRef.whereField("date", isEqualTo: self.selectDate!)
                        .getDocuments { (querySnapshot, error) in
                            if let error = error {
                                fatalError("\(error)")
                            } else if querySnapshot?.documents != nil && !querySnapshot!.documents.isEmpty  {
                                self.planData = PlanData(document: querySnapshot!.documents[0])
                                if self.planData.attendance == "出社" {
                                    self.member[0].append(self.planData)
                                } else if self.planData.attendance == "在宅"{
                                    self.member[1].append(self.planData)
                                }
                            self.loadedIndex += 1
                            }
                            self.tableView.reloadData()
                        }
                }
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
        backButton.layer.backgroundColor = UIColor.white.cgColor
        backButton.layer.borderWidth = 2
        backButton.layer.cornerRadius = 10
        backButton.layer.borderColor = CGColor(red: 0.96, green: 0.51, blue: 0.40, alpha: 1.0)
        
        backButton.layer.shadowColor = UIColor.gray.cgColor
        backButton.layer.shadowOpacity = 1 //影の色の透明度
        backButton.layer.shadowRadius = 3 //影のぼかし
        backButton.layer.shadowOffset = CGSize(width: 2, height: 2) //影の方向　width、heightを負の値にすると上の方に影が表示される
        
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
        let nameLabel = cell.viewWithTag(1) as! UILabel
        let healthButton = cell.viewWithTag(3) as! UIButton
        
        if loadedIndex > 0 {
            //名前表示
            nameLabel.text = (member[indexPath.section][indexPath.row].name)
            
            /*//出社時間表示
            let timeLabel = cell.viewWithTag(2) as! UILabel
            let formatter = DateFormatter()
            let startTimeStr = formatter.string(from: member[indexPath.section][indexPath.row].startTime!)
            let endTimeStr = formatter.string(from: member[indexPath.section][indexPath.row].endTime!)
            timeLabel.text = "\(startTimeStr)" + "→" + "\(endTimeStr)"*/
            
            //体調表示
            if member[indexPath.section][indexPath.row].healthStatus == "Good"{
                healthButton.setImage(img1, for: .normal)
            } else if member[indexPath.section][indexPath.row].healthStatus == "Bad"{
                healthButton.setImage(img2, for: .normal)
            } else {
                healthButton.setImage(img0, for: .normal)
            }
        } else {
        nameLabel.text = "登録なし"
        }
        
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
