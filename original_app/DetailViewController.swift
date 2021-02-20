//
//  DetailViewController.swift
//  original_app
//
//  Created by 辻志保美 on 2021/02/11.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    
    
    var header = [String]()
    var member = [[String]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        header = ["出社", "在宅"]
        
        for _ in 0...1 {
            member.append([])
        }
        
        //出社・在宅しているメンバー
        member[0] = ["aa", "bb", "cc"]
        member[1] = ["cc", "dd", "ee"]
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addButton.imageView?.contentMode = .scaleAspectFit
        addButton.contentHorizontalAlignment = .fill
        addButton.contentVerticalAlignment = .fill
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
        cell.textLabel?.text = member[indexPath.section][indexPath.row]
        return cell
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
