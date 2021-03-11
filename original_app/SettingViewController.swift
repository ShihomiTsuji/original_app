//
//  SettingViewController.swift
//  original_app
//
//  Created by 辻志保美 on 2021/03/11.
//

import UIKit
import Firebase

class SettingViewController: UIViewController {
    @IBOutlet weak var displayNameTextField: UITextField!
    
    @IBAction func handleLogoutButton(_ sender: Any) {
        // ログアウトする
               try! Auth.auth().signOut()
        
               // ログイン画面を表示する
               let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
               self.present(loginViewController!, animated: true, completion: nil)

               // ログイン画面から戻ってきた時のためにホーム画面（index = 0）を選択している状態にしておく
               tabBarController?.selectedIndex = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 表示名を取得してTextFieldに設定する
        let user = Auth.auth().currentUser
        if let user = user {
            displayNameTextField.text = user.displayName
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
