//
//  AppDelegate.swift
//  Map Share
//
//  Created by Elon Rubin on 11/30/16.
//  Copyright © 2016 Elon Rubin. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import RealmSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let realm = try! Realm()
    lazy var places: Results<Place> = { self.realm.objects(Place.self)  }()
    
    // This handles deeplink
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url.host!)
        // handle the url
        let urlHandle = url.host!
        // 1 - split string into an array of strings
        let urlArray = urlHandle.characters.split{$0 == ","}.map(String.init)
        // 2 - create data from array
        let lat = Double(urlArray[0])!
        let long = Double(urlArray[1])!
        let otherPersonTruncated = String(urlArray[2])!
        let placename = String(urlArray[3])!
        let otherPerson = otherPersonTruncated.replacingOccurrences(of: "+", with: " ", options: NSString.CompareOptions.literal)
        // 3 - Reverse geocode with above data. This function also saves the share place
        reverseGeocoding(latitude: lat, longitude: long, otherPerson: otherPerson, placename: placename)

        
        return true
    }


    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
        if #available(iOS 10.0, *) {
            self.saveContext()
        } else {
            // Fallback on earlier versions
        }
    }

    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Map_Share")
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

    @available(iOS 10.0, *)
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
    // This creates a CLPlacemark Object and then saves it (and associated data) to Realm
    func reverseGeocoding(latitude: Double, longitude: Double, otherPerson: String, placename: String)  {
        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)
        let location = CLLocation(latitude: lat, longitude: long)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print(error!)
                return
            }
            else if (placemarks?.count)! > 0 {
                let placemark = placemarks![0]
                self.savePlace(placemark: placemark, otherPerson: otherPerson, lat: latitude, long: longitude, placename: placename)
            }
        })
        
    }

    func savePlace (placemark: CLPlacemark, otherPerson: String, lat: Double, long: Double, placename: String) {
        let idString = generateRandomNumber()
        if places.filter("id == %@", idString).first == nil {
            realm.beginWrite()
            let place = Place()
            if placemark.name != nil {
                place.name = placemark.name!
            } else {
                
            }
            place.id = idString
            place.name = placemark.name!
            place.address = "\(placemark.subThoroughfare!) \(placemark.thoroughfare!), \(placemark.locality!), \(placemark.administrativeArea!) \(placemark.postalCode!)"
            place.lat = lat
            place.long = long
            place.otherName = otherPerson
            place.sent = false
            place.createdDate = getCurrentDate().currentDate as NSDate
            place.convertedDate = getCurrentDate().convertedDate
            realm.add(place, update: true)
            
            do {
                try realm.commitWrite()
                print("commiting write")
                self.goToMainScreen()
            }
            catch (let e)
            {
                print("Y U NO REALM ? \(e)")
            }
            
            
        } else {
            savePlace(placemark: placemark, otherPerson: otherPerson, lat: lat, long: long, placename: placename)
        }
    }
    
    func generateRandomNumber () -> String {
        let number: UInt32 =  1000000
        let randomNumber = Int(arc4random_uniform(number))
        
        return String(randomNumber)
    }
    
    func getCurrentDate () -> (currentDate:Date, convertedDate: String) {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        let convertedDate = dateFormatter.string(from: currentDate)
        return (currentDate, convertedDate)
    }
    
    func goToMainScreen () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let startViewController = storyboard.instantiateViewController(withIdentifier: "navcontroller") as! UINavigationController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = startViewController;
        self.window?.makeKeyAndVisible()
        
    }
}

