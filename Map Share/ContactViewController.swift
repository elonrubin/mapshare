//
//  ContactViewController.swift
//  Map Share
//
//  Created by Elon Rubin on 12/1/16.
//  Copyright © 2016 Elon Rubin. All rights reserved.
//

import UIKit
import AddressBook
import ContactsUI
import MessageUI
import Contacts
import MapKit
import AddressBook
import RealmSwift

@available(iOS 9.0, *)
class ContactViewController: UIViewController, CNContactPickerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    //--------------------------------------
    // MARK: Variables
    //--------------------------------------
    let searchController = UISearchController(searchResultsController: nil)
    var selectedItem: MKPlacemark?
    
    // UISearchUpdating Data Variables
    var contacts = [CNContact]()
    var searchResults: [String] = []
    var contactNames = [String]()
    
    var otherPerson = "" // this is populated when a user taps on a contact and is used as a variable to save a share
    
    // Realm Variables
     let realm = try! Realm()
     lazy var places: Results<Place> = { self.realm.objects(Place.self)  }()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//print(selectedItem)
        tableView.delegate = self
        tableView.dataSource = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        
        // Obscurebackgroundpresentation is only available in 9.1 I added logic to have backwards compatabilty
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            if searchController.searchBar.text != nil {
                searchController.isActive = true
            }
        }
        tableView.tableHeaderView = searchController.searchBar
    // This Method checks whether a user gave permission to access contacts. If it does, it calls the populatecontacts() method
        self.populateContacts()


    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    func populateContacts() {
          let store = CNContactStore()
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        do {
            try store.enumerateContacts(with: request) {
                (contact, stop) in
                // Array containing all unified contacts from everywhere

                let completeName = contact.givenName + " " + contact.familyName
                self.contactNames.append(completeName)

            }
            
             let contactPickerViewController = CNContactPickerViewController()
            contactPickerViewController.delegate = self
            
            SwiftMethods.performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }
        catch {
            print("unable to fetch contacts")
        }
        
    }
    
   

    
    
    //--------------------------------------
    // MARK: Tableview
    //--------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // This logic implemets SearchResultsUpdating
        if searchController.isActive {
            return searchResults.count
        } else {

            return contactNames.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let contact = (searchController.isActive) ? searchResults[indexPath.row] : contactNames[indexPath.row]
        cell.textLabel?.text = contact
        return cell
    }
    
    
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var root: String?
      
        
         // This logic implemets SearchResultsUpdating
        if (searchController.isActive) {
            otherPerson = searchResults[indexPath.row]
            searchController.dismiss(animated: false, completion: nil)
        } else {
            otherPerson = contactNames[indexPath.row]
        }
        

      
        if selectedItem!.name != nil {
        root = "Check out \(selectedItem!.name!):"
        } else {
            root = "Check out:"
        }
        
        let defaults = UserDefaults.standard
        let name = defaults.object(forKey: "Name") as! String
        // For deeplinking, it's necessary to put a plus between the first and last name.
        let truncatedName = name.replacingOccurrences(of: " ", with: "+", options: NSString.CompareOptions.literal)
        let deeplinkURL = "placeshareapp://"
        
        let lat = String(describing: selectedItem!.coordinate.latitude)
        let long = String(describing: selectedItem!.coordinate.longitude)
        // This string is used when sharing
        let shareString = deeplinkURL + lat + "," + long + "," + truncatedName + "," + selectedItem!.name!
        
        
        // Activity View Implementation
        let vc = UIActivityViewController(activityItems: [root,shareString], applicationActivities: nil)
//                vc.excludedActivityTypes = [UIActivityType.]
        SwiftMethods.performUIUpdatesOnMain {
            self.present(vc, animated: true, completion: nil)
        }

        // Completion handler - if a person shares something, it saves te share and brings up an alert
        vc.completionWithItemsHandler = { activity, success, items, error in
            //            if activity == UIActivityType.mail {
            //                let mail = UIActivityType.mail
            if (success) {
                print("shared")
                  // insert save
                
             // This method saves place information
            self.savePlace()
                
                // insert alert
                
                
                
                let alertController = UIAlertController(title: "Success", message: "Your share went through and saved to your history. Going to home screen now.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                  self.navigationController!.popToRootViewController(animated: true)

                }
                
                      alertController.addAction(okAction)
                    
                    SwiftMethods.performUIUpdatesOnMain {
                        self.present(alertController, animated: true, completion: nil)
                    }
                   
                    
                    
                
                
            } else {
                print("not shared")
            }
        }
    }

    func makeContactsController() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    func showContacts() {
        let contactPickerViewController = CNContactPickerViewController()
        
        contactPickerViewController.predicateForEnablingContact = NSPredicate(format: "birthday != nil")
        
        contactPickerViewController.delegate = self
        
        present(contactPickerViewController, animated: true, completion: nil)
    }
    
    func filterControllerForSearchText(searchText: String) {
        searchResults = contactNames.filter({ (contact: String) -> Bool in
//            let formatter = CNContactFormatter()
//            let name = contact.givenName + " " + contact.familyName
            
            let nameMatch = contact.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
//            rangeOfString(searchText,options: NSString.CompareOptions.CaseInsensitiveSearch)
            return nameMatch != nil
        })
        
    }
    
   
    
    func updateSearchResults(for searchController: UISearchController) {

        
        if let searchText = searchController.searchBar.text {
            filterControllerForSearchText(searchText: searchText)
//            searchContactDataBaseOnName(name: searchText)
            SwiftMethods.performUIUpdatesOnMain {
                 self.tableView.reloadData()
            }
           
            
        }
        
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        navigationController!.popViewController(animated: true)
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
    
    func savePlace () {
        // A saved place must have a unique identifier. I created a randomizer function and then check whether the id exists (to prevent a fatal crash). If it doesn't, it proceeds to save the place. If it does, it loops back to the beginning of the function
        let idString = generateRandomNumber()
        if places.filter("id == %@", idString).first == nil {
          realm.beginWrite()
            let place = Place()
            if selectedItem!.name != nil {
                place.name = selectedItem!.name!
            } else {
                
            }
            place.id = idString

            // Bug - the forced unwrapping in this variable needs to be changed to optionals. And there needs to be added logic to compose different strings based upon what's avaialbie
                place.address = "\(self.selectedItem!.subThoroughfare!) \(self.selectedItem!.thoroughfare!), \(self.selectedItem!.locality!), \(self.selectedItem!.administrativeArea!) \(selectedItem!.postalCode!)"
            place.lat = Double(selectedItem!.coordinate.latitude)
            place.long = Double(selectedItem!.coordinate.longitude)
            place.otherName = self.otherPerson
            place.sent = true
            place.createdDate = getCurrentDate().currentDate as NSDate
            place.convertedDate = getCurrentDate().convertedDate
            
            realm.add(place, update: true)
            
            do {
                try realm.commitWrite()
                print("commiting write")
            }
            catch (let e)
            {
                print("Y U NO REALM ? \(e)")
            }
            
            
        } else {
            savePlace()
        }
    }
}


extension UIViewController {

    func showAlertMessage(_ message: String, okButtonTitle: String = "Ok") -> Void {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okButtonTitle, style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
