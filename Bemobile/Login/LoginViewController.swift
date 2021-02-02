//
//  LoginViewController.swift
//  Bemobile
//
//  Created by Albert on 28/01/2021.
//  Copyright © 2021 Albert. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var _username: UITextField!
    @IBOutlet var _password: UITextField!
    @IBOutlet var _login_button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let preferences = UserDefaults.standard
        
        if (preferences.object(forKey: "session") != nil) {
            LoginDone()
        }
        else{
            LoginToDo()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    // Show the Navigation Bar
    self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    // Hide the Navigation Bar
    self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func LoginButton(_ sender: Any) {
        
        let username = _username.text
        let password = _password.text
        
        if(username == "" || password == "")
        {
            return
        }
        DoLogin(_user: username!, _psw: password!)
        
        if(_username.isEnabled == false || _password.isEnabled == false){
            performSegue(withIdentifier: "SegueToProducts", sender: sender)
        }
        
    }
    func DoLogin(_user:String, _psw:String){
        if(_user == "user" || _psw == "password"){
            self.LoginDone()
        }else{
            self.LoginToDo()
        }
    }
    
    func LoginDone(){
        _username.isEnabled = false
        _password.isEnabled = false
        
        _login_button.setTitle("Logout", for: .normal)
        
    }
    
    func LoginToDo(){
        _username.isEnabled = true
        _password.isEnabled = true
        
        _login_button.setTitle("Login", for: .normal)
    }
}
