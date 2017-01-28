//
//  SharedControl.swift
//  TravelApp
//
//  Created by rawat on 22/01/17.
//  Copyright © 2017 Pankaj Rawat. All rights reserved.
//

import UIKit

class SharedData: NSObject {
    
//    var API_URL: String = "http://localhost:3000"
    var API_URL: String = "https://travel-api-aviabird.herokuapp.com"
    var token: String = ""
    
    func getToken() -> String {
        if token == "" {
            let data = UserDefaults.standard.object(forKey: "Token") as? String
            if (data != nil) {
                self.token = data!
            }
        }
        
        return self.token
    }
    
    func setToken() {
        UserDefaults.standard.set(self.token, forKey: "Token")
    }
    
    func clearAll() {
        self.token = ""
        UserDefaults.standard.removeObject(forKey: "Token")
    }
    
    func currentUser() -> User? {
        let user = UserDefaults.standard.object(forKey: "User") as? User
        
        if (user != nil) {
            return user!
        }
        
        return nil
    }
    
}
