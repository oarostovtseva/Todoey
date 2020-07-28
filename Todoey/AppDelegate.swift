//
//  AppDelegate.swift
//  Destini
//
//  Created by Olena Rostovtseva on 24.07.2020.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import RealmSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            _ = try Realm()
        } catch {
            print("Error init realm \(error)")
        }
        return true
    }
}
