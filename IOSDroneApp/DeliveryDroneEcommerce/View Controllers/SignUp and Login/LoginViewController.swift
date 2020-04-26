//
//  LoginViewController.swift
//  DeliveryDroneEcommerce
//
//  Created by Michael Peng on 4/8/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit
import Firebase
import BetterSegmentedControl
import TextFieldEffects
import PMSuperButton

class LoginViewController: UIViewController {
    
    //    login
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: YoshikoTextField!
    @IBOutlet weak var loginLabel: UILabel!
    
    //    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var registerLabel: UILabel!
    
    @IBOutlet weak var loginButton: PMSuperButton!
    @IBOutlet weak var switchOutlet: UISegmentedControl!
    @IBOutlet weak var emailAddress: YoshikoTextField!
    
    @IBOutlet weak var signUpButton: PMSuperButton!
    
    @IBOutlet weak var Regpass: YoshikoTextField!
    
    @IBOutlet weak var shippingAddress: YoshikoTextField!
    
    
    //    register
    
    var loginOn : Bool = true
    
    //
    @IBOutlet weak var FirstName: YoshikoTextField!
    @IBOutlet weak var LastName: YoshikoTextField!
    
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerLabel.isHidden = true
        self.emailAddress.isHidden = true
        self.Regpass.isHidden = true
        self.FirstName.isHidden = true
        self.LastName.isHidden = true
        self.signUpButton.isHidden = true
        self.shippingAddress.isHidden = true
        registerLabel.alpha = 0
        self.emailAddress.alpha = 0
        self.Regpass.alpha = 0
        self.FirstName.alpha = 0
        self.LastName.alpha = 0
        self.signUpButton.alpha = 0
        self.shippingAddress.alpha = 0
        
        //        let control = BetterSegmentedControl(frame: CGRect(x: 0, y: 0, width: 300, height: 44), segments: LabelSegment.segments(withTitles: ["One", "Two", "Three"],
        //        normalFont: UIFont(name: "HelveticaNeue-Light", size: 14.0)!,
        //        normalTextColor: .lightGray,
        //        selectedFont: UIFont(name: "HelveticaNeue-Bold", size: 14.0)!,
        //        selectedTextColor: .white),
        //        index: 1,
        //        options: [.backgroundColor(.darkGray),
        //                  .indicatorViewBackgroundColor(.blue)])
        //
        //        switchOutlet.
        
        
        loginButton.layer.cornerRadius = 5
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowRadius = 5
        loginButton.layer.shadowOpacity = 0.7
        
        
        
        
        signUpButton.layer.cornerRadius = 5
        signUpButton.layer.shadowColor = UIColor.black.cgColor
        signUpButton.layer.shadowRadius = 5
        signUpButton.layer.shadowOpacity = 0.7
        
        //        accountButton.layer.cornerRadius = accountButton.frame.height / 3
        //        accountButton.layer.shadowColor = UIColor.black.cgColor
        //        accountButton.layer.shadowRadius = 5
        //        accountButton.layer.shadowOpacity = 0.7
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "en_US")
        let time = formatter.string(from: date)
        
        
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
        
        
        loginButton.touchUpInside {
            self.loginButton.showLoader(userInteraction: false)
            //            var state: UIControl.State = UIControl.State()
            self.loginButton.setTitle("", for: .normal)
            print("hi")
            Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
                if (error == nil) {
                    
                    self.ref.child("UserInfo").child(Auth.auth().currentUser!.uid).child("Information").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        guard let value = snapshot.value as? NSDictionary else {
                            print("No Data!!!")
                            return
                        }
                        let status = value["Status"] as! String
                        
                        
                        print (status)
                        if (status == "User") {
                            self.performSegue(withIdentifier: "toUserHome", sender: self)
                        }
                        else {
                            self.performSegue(withIdentifier: "toCompanyHome", sender: self)
                        }
                        
                        
                    }) { (error) in
                        print("error:\(error.localizedDescription)")
                    }
                    //
                    
                } else {
                    
                    
                    let alert = UIAlertController(title: "Login Error", message: "Incorrect username or password", preferredStyle: .alert)
                    let forgotPassword = UIAlertAction(title: "Forgot Password?", style: .default, handler: { (UIAlertAction) in
                        //do the forgot password shit
                    })
                    
                    let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { (UIAlertAction) in
                        //do nothing
                        self.loginButton.hideLoader()
                        //            var state: UIControl.State = UIControl.State()
                        self.loginButton.setTitle("Login", for: .normal)
                    })
                    
                    alert.addAction(forgotPassword)
                    alert.addAction(cancel)
                    self.present(alert, animated: true, completion: nil)
                    print("error with logging in: ", error!)
                    self.loginButton.hideLoader()
                    self.loginButton.hideLoader()
                    self.loginButton.setTitle("Login", for: .normal)
                }
                self.loginButton.hideLoader()
                //            var state: UIControl.State = UIControl.State()
                self.loginButton.setTitle("Login", for: .normal)
            }
        }
        signUpButton.touchUpInside {
            self.signUpButton.showLoader(userInteraction: true)
            self.signUpButton.setTitle("", for: .normal)
            
            
            print("hi")
            if (self.FirstName.text?.isEmpty ?? true || self.LastName.text?.isEmpty ?? true || self.emailAddress.text?.isEmpty ?? true || self.Regpass.text?.isEmpty ?? true) {
                print("jeff")
//                self.switchButton(self.switchOutlet)
                print("THERE IS AN ERROR")
                let alert = UIAlertController(title: "Registration Error", message: "Please make sure you have completed filled out every textfield", preferredStyle: .alert)
                
                let OK = UIAlertAction(title: "OK", style: .default) { (alert) in
                    self.signUpButton.hideLoader()
                    self.signUpButton.setTitle("Sign Up", for: .normal)
                    return
                }
                
                alert.addAction(OK)
                self.present(alert, animated: true, completion: nil)
                
            } else {
                Auth.auth().createUser(withEmail: self.emailAddress.text!, password: self.Regpass.text!) { (user, error) in
                    if (error == nil) {
                        self.ref.child("UserInfo").child(Auth.auth().currentUser!.uid).child("Information").setValue(["FirstName" : self.FirstName.text, "LastName" : self.LastName.text, "Address" : self.shippingAddress.text, "Email" : self.emailAddress.text])
                        self.ref.child("UserInfo").child(Auth.auth().currentUser!.uid).child("Information").updateChildValues(["Status" : "User"])
                        
                        self.performSegue(withIdentifier: "toUserHome", sender: self)
                        
                        //                                                self.performSegue(withIdentifier: "UserToLogin", sender: self)
                        //                    self.performSegue(withIdentifier: "goToMainMenu", sender: self)
                    } else {
                        //                    SVProgressHUD.dismiss()
                        let alert = UIAlertController(title: "Registration Error", message: error?.localizedDescription as! String, preferredStyle: .alert)
                        
                        let OK = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                            self.password.text = ""
                            self.signUpButton.hideLoader()
                            self.signUpButton.setTitle("Sign Up", for: .normal)
                        })
                        
                        alert.addAction(OK)
                        self.present(alert, animated: true, completion: nil)
                        print("--------------------------------")
                        print("Error: \(error?.localizedDescription)")
                        print("--------------------------------")
                    }
                }
                
                
            }
            
        }
        
        
    }
    
    
    
    @IBAction func switchButton(_ sender: Any) {
        if loginOn {
            loginLabel.isHidden = true
            email.isHidden = true
            password.isHidden = true
            loginButton.isHidden = true
            loginLabel.alpha = 0
            self.email.alpha = 0
            self.password.alpha = 0
            self.loginButton.alpha = 0
            registerLabel.isHidden = false
            self.emailAddress.isHidden = false
            self.Regpass.isHidden = false
            self.FirstName.isHidden = false
            self.LastName.isHidden = false
            self.signUpButton.isHidden = false
            self.shippingAddress.isHidden = false
            
            UIView.animate(withDuration: 1.0, animations: { () -> Void in
                self.registerLabel.alpha = 1
                self.emailAddress.alpha = 1
                self.Regpass.alpha = 1
                self.FirstName.alpha = 1
                self.LastName.alpha = 1
                self.signUpButton.alpha = 1
                self.shippingAddress.alpha = 1
                
            })
            
            loginOn = false
            
        }
        else {
            self.registerLabel.isHidden = true
            self.emailAddress.isHidden = true
            self.Regpass.isHidden = true
            self.FirstName.isHidden = true
            self.LastName.isHidden = true
            self.signUpButton.isHidden = true
            self.shippingAddress.isHidden = true
            self.registerLabel.alpha = 0
            self.emailAddress.alpha = 0
            self.Regpass.alpha = 0
            self.FirstName.alpha = 0
            self.LastName.alpha = 0
            self.signUpButton.alpha = 0
            self.shippingAddress.alpha = 0
            
            
            loginLabel.isHidden = false
            email.isHidden = false
            password.isHidden = false
            loginButton.isHidden = false
            UIView.animate(withDuration: 1.0, animations: { () -> Void in
                self.loginLabel.alpha = 1
                self.email.alpha = 1
                self.password.alpha = 1
                self.loginButton.alpha = 1
            })
            
            loginOn = true
            
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
