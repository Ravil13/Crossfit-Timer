//
//  AppDelegate.swift
//  Crossfit Timer
//
//  Created by Равиль Вильданов on 07.04.18.
//  Copyright © 2018 Равиль Вильданов. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Меняем цвет навигаишон контролеру
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        UINavigationBar.appearance().isTranslucent = true;
        // меняем цвет шрифта у навигаишон контролера
        UINavigationBar.appearance().tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        //TabBar
        UITabBar.appearance().tintColor = #colorLiteral(red: 0.961902678, green: 0.650972724, blue: 0.1936408281, alpha: 1)
        UITabBar.appearance().barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        // меняем цвет title(заголовка)
        //  если у нас получилось присвоить этот шрифт констнте, то
        if let barFont = UIFont(name: "HelveticaNeue", size: 24) {
            // то мы присваевыем значение этой константы в текст шапки
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: barFont]
        }
        
        return true
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
    }


}

