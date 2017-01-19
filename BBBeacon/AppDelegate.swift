//
//  AppDelegate.swift
//  BBBeacon
//
//  Created by Bryan A Bolivar M on 1/17/17.
//  Copyright © 2017 Bolivar. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var location: CLLocation?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //let b1 = Beacon(name: "Casa Julieth", latitude: 10.96089, longitude: -74.7925987555, url: "url", school: "", beaconId: 01, uuid: "00001", range: 150)
        //let b2 = Beacon(name: "Casa Bryan", latitude: 10.9547341, longitude: -74.788887, url: "url", school: "", beaconId: 02, uuid: "00003", range: 150)
        //let b3 = Beacon(name: "McDonalds 93", latitude: 11.004883, longitude: -74.8268273, url: "url", school: "", beaconId: 03, uuid: "00002", range: 150)
        //let b4 = Beacon(name: "Mexico", latitude: 51.50998, longitude: -0.1337, url: "url", school: "", beaconId: 04, uuid: "00002", range: 150)
        let b5 = Beacon(name: "Dunkin Donuts 84", latitude: 10.96089, longitude: -74.7925987555, url: "url", school: "", beaconId: 05, uuid: "23A01AF0-232A-4518-9C0E-323FB773F5EF", range: 150)
        
        BeaconManager.sharedInstance.trackBeacons()
        BeaconManager.sharedInstance.delegate = self
        BeaconManager.sharedInstance.registerBeacons(newBeacons: [b5])

        //Requesting Authorization for User Interactions
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            print(granted)
        }
        return true
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        BeaconManager.sharedInstance.trackInBackground()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        BeaconManager.sharedInstance.trackInBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        BeaconManager.sharedInstance.trackInBackground()
        
        self.sendNotification(title: "Good bye", message: "ciao", id: "ciao", at: Date().addingTimeInterval(3) )
        
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "BBBeacon")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
    }
    
    func sendNotification(title: String, message: String, id: String, at: Date ) {
        print(title)
        let notification = UILocalNotification()
        notification.alertBody =  title
        notification.alertAction = message
        notification.fireDate = at
        UILocalNotificationDefaultSoundName
        notification.userInfo = ["title": title, "UUID": id]
        UIApplication.shared.scheduleLocalNotification(notification)
    }
}

extension AppDelegate: BeaconManagerDelegate {
    func enteredInBeaconZone(beacon: Beacon) {
        self.sendNotification(title: "You are in \(beacon.name) at \(Date())", message: "open for more details", id: beacon.uuid, at: Date())
    }
    
    func updatedToLocation(location: CLLocation) {
        self.location = location
    }
    
    func insideBeaconRegion(beacon: Beacon) {
        
    }
}

