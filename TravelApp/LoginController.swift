//
//  LoginController.swift
//  TravelApp
//
//  Created by Pankaj Rawat on 21/01/17.
//  Copyright © 2017 Pankaj Rawat. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    
    override var shouldAutorotate: Bool { return false }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    
    var sharedData = SharedData()
    var homeController: HomeController?
    
    let inputContainerView:  UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.rgb(red: 80, green: 101, blue:  161, alpha: 1)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    // For creating alerts
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Got It", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleLogin() {
        print("User Login")
        
        guard let email = emailTextField.text, isValidEmail(testStr: email) else {
            self.createAlert(title: "Error", message: "Enter valid email")
            return
        }
        
        guard let password = passwordTextField.text, password.characters.count > 3 && password.characters.count <= 32 else {
            self.createAlert(title: "Error", message: "Enter valid password(4 to 32 characters)")
            return
        }
        
        let url = URL(string: "\(sharedData.API_URL)/authenticate")!
        let params = ["email": "\(emailTextField.text!)", "password": "\(passwordTextField.text!)"]
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let jsonData = try? JSONSerialization.data(withJSONObject: params)
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                if let data = data {
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
                        if let error = ((jsonResult["error"] as? NSDictionary)?["user_authentication"] as? NSArray)?[0]{
                            DispatchQueue.main.sync(execute: {
                                self.createAlert(title: "Error", message: "\(error)")
                            })
                        }else {
                            if let authToken = jsonResult["auth_token"] as? String {
                                self.sharedData.token = authToken
                                self.sharedData.setToken()
                                DispatchQueue.main.sync(execute: {
                                    self.dismiss(animated: true, completion: { 
                                        self.homeController?.fetchTrips()
                                    })
                                })
                            }
                        }
                    } catch {
                        DispatchQueue.main.sync(execute: {
                            self.createAlert(title: "Data Incorrect", message: "Please Check The data")
                        })
                    }
                }
            }
        })
        task.resume()
        print("User Login Success")
    }
    
    func handleRegister() {
        
        print("User Register")
        
        guard let email = emailTextField.text, isValidEmail(testStr: email) else {
            print("Invalid Email")
            return
        }
        
        guard let password = passwordTextField.text, password.characters.count > 7 && password.characters.count <= 32 else {
            print("Invalid Password")
            return
        }
        
        let url = URL(string: "\(sharedData.API_URL)/users/create")!
        let params = ["user": ["email": "\(emailTextField.text!)", "password": "\(passwordTextField.text!)", "password_confirmation": "\(confirmPasswordTextField.text!)"]]
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let jsonData = try? JSONSerialization.data(withJSONObject: params)
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                if let data = data {
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
                        //                                print(jsonResult["password_confirmation"])
                        if let error = (jsonResult["password_confirmation"] as? NSArray)?[0] {
                            DispatchQueue.main.sync(execute: {
                                self.createAlert(title: "Error", message: "\(error)")
                            })
                        }else {
                            DispatchQueue.main.sync(execute: {
                                let alert = UIAlertController(title: "Successfull Sign Up", message: "Welcome To Trip Diary", preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: "Let's Start", style: .default, handler: { (action) in
                                    self.handleLogin()
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                            })
                        }
                    } catch {
                        DispatchQueue.main.sync(execute: {
                            self.createAlert(title: "Data Incorrect", message: "Please Check The data")
                        })
                    }
                }
            }
        })
        task.resume()
        
        print("User Registration Success")
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 220, green: 220, blue: 220, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let passwordSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 220, green: 220, blue: 220, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let confirmPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Confirm Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profileIMG")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    let loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        //change height of input container view
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        // Reposition input container view after removing name field
        inputsContainerViewcenterYAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 5 : 30
        
        //Change height of email text field
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        //Change height of password text field
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addBackground(imageName: "LoginBG")
        
        view.addSubview(inputContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        setupLoginRegisterSegmentedControl()
    }
    
    func setupLoginRegisterSegmentedControl() {
        // need x, y, height, width
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func setupProfileImageView() {
        // need x, y, height, width
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var inputsContainerViewcenterYAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputsContainerView() {
        // need x, y, height, width
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerViewcenterYAnchor = inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30)
        inputsContainerViewcenterYAnchor?.isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputContainerView.addSubview(emailTextField)
        inputContainerView.addSubview(emailSeparatorView)
        inputContainerView.addSubview(passwordTextField)
        inputContainerView.addSubview(passwordSeparatorView)
        inputContainerView.addSubview(confirmPasswordTextField)
        
        // need x, y, height, width
        emailTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor, constant: -12).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        // need x, y, height, width
        emailSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // need x, y, height, width
        passwordTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailSeparatorView.topAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor, constant: -12).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        // need x, y, height, width
        passwordSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        passwordSeparatorView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        passwordSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        passwordSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // need x, y, height, width
        confirmPasswordTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        confirmPasswordTextField.topAnchor.constraint(equalTo: passwordSeparatorView.bottomAnchor).isActive = true
        confirmPasswordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor, constant: -12).isActive = true
        confirmPasswordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3).isActive = true
    }
    
    func setupLoginRegisterButton() {
        // need x, y, height, width
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
}
