//
//  TabBarController.swift
//  original_app
//
//  Created by 辻志保美 on 2021/02/20.
//

import UIKit
import Firebase

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UITabBar.appearance().barTintColor = UIColor(red: 0.97, green: 0.64, blue: 0.56, alpha: 1.0)
        UITabBar.appearance().tintColor = UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //currenUserがnilならログインしていない
        if Auth.auth().currentUser == nil{
            //ログインしていない時の処理
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(loginViewController!, animated: true, completion: nil)
            
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
