//
//  SignUpViewController.swift
//  Pods
//
//  Created by Apprentice on 4/3/16.
//
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    
    
    @IBAction func userTappedBackground(sender: AnyObject) {
        view.endEditing(true)
    }
    
    let ref = Firebase(url: "https://flickering-heat-6121.firebaseio.com/")

    @IBOutlet weak var nickname: UITextField!
    
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBAction func signUp(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        ref.createUser(self.email.text, password: self.password.text,
                       withValueCompletionBlock: { error, result in
                        if error != nil {
                            // something went wrong creating user, throw an error
                            let alertController = UIAlertController(title: "Ahh!!!", message:
                                "You need to put in different/better information", preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "I'll do better next time", style: UIAlertActionStyle.Default,handler: nil))
                            self.presentViewController(alertController, animated: true, completion: nil)
                        } else {
                            // create user and sign in
                            let uid = result["uid"] as? String
                            print("Successfully created user account with uid: \(uid)")
                            self.ref.authUser(self.email.text, password: self.password.text) {
                                error, authData in
                                if error != nil {
                                } else {
                                    print(authData.uid)
                                    print(authData.providerData)
                                    
                                    let newUser = [
                                        "uid" : authData.uid,
                                        "provider": authData.provider,
                                        "displayName": self.nickname.text,
                                        "phoneNumber": self.phoneNumber.text,
                                        "deviceToken": appDelegate.deviceTokenFireBase
                                    ]
                                    
                                    self.ref.childByAppendingPath("users").childByAppendingPath(self.phoneNumber.text).setValue(newUser)
                                    
                                    self.performSegueWithIdentifier("SignUpToMainPage", sender: self)
                                }
                            }
                            
                        }
                        
        })
    }
    
    @IBAction func logIn(sender: AnyObject) {
        ref.authUser(self.email.text, password: self.password.text) {
            error, authData in
            if error != nil {
                let alertController = UIAlertController(title: "Ahh!!!", message:
                    "Your username or password is incorrect :(", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "I'll try again", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
        
                print(error.description)
            } else {
                print(authData.uid)
                print(authData.providerData)
                self.performSegueWithIdentifier("SignUpToMainPage", sender: self)
            }
         }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
