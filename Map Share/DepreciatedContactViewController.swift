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
class DepreciatedContactViewController: UIViewController, CNContactPickerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    //--------------------------------------
    // MARK: Variables
    //--------------------------------------
    let searchController = UISearchController(searchResultsController: nil)
    var selectedItem: MKPlacemark?
    var contacts = [CNContact]()
    //    var searchResults: [CNContact] = []
    var searchResults: [String] = []
    var contactNames = [String]()
    var otherPerson = ""
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
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            if searchController.searchBar.text != nil {
                searchController.isActive = true
            }
        }
        tableView.tableHeaderView = searchController.searchBar
        self.getNewContacts()
        //         tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")
        // Do any additional setup after loading the view.
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addressToContactSegue" {
            let vc = segue.destination as! ContactViewController
            vc.selectedItem = selectedItem
        }
    }
    
    
    // Authorize contacts
    //    func checkAccessStatus(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
    //
    //
    //        if #available(iOS 9.0, *) {
    //            let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
    //            switch authorizationStatus {
    //            case .authorized:
    //                completionHandler(true)
    //            case .denied, .notDetermined:
    //                self.store.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
    //                    if access {
    //                        completionHandler(access)
    //                    } else {
    //                        print("access denied")
    //                    }
    //                })
    //            default:
    //                completionHandler(false)
    //            }
    //        } else {
    //            // Fallback on earlier versions
    //        }
    //
    //
    //    }
    
    func getNewContacts() {
        let store = CNContactStore()
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        do {
            try store.enumerateContacts(with: request) {
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                //                self.contacts.append(contact)
                let completeName = contact.givenName + " " + contact.familyName
                self.contactNames.append(completeName)
                //                let formatter = CNContactFormatter()
                //
                //                self.contactNames.append(formatter.string(from: contact)!)
            }
            
            let contactPickerViewController = CNContactPickerViewController()
            contactPickerViewController.delegate = self
            
            SwiftMethods.performUIUpdatesOnMain {
                self.tableView.reloadData()
                //                self.present(contactPickerViewController, animated: true, completion: nil)
            }
        }
        catch {
            print("unable to fetch contacts")
        }
        
    }
    
    func getContacts() {
        let store = CNContactStore()
        
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            store.requestAccess(for: .contacts, completionHandler: { (authorized: Bool, error: NSError?) -> Void in
                if authorized {
                    self.retrieveContactsWithStore(store: store)
                }
                } as! (Bool, Error?) -> Void)
        } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            self.retrieveContactsWithStore(store: store)
        }
    }
    
    
    func retrieveContactsWithStore(store: CNContactStore) {
        do {
            let groups = try store.groups(matching: nil)
            let predicate = CNContact.predicateForContactsInGroup(withIdentifier: groups[0].identifier)
            //let predicate = CNContact.predicateForContactsMatchingName("John")
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactEmailAddressesKey] as [Any]
            
            let localContacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
            self.contacts = localContacts
            for contact in contacts {
                let completeName = contact.givenName + " " + contact.familyName
                contactNames.append(completeName)
                
            }
            
            
            SwiftMethods.performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
            
        } catch {
            print(error)
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if searchController.isActive {
            return searchResults.count
        } else {
            //            return contacts.count
            return contactNames.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //        let contact = (searchController.isActive) ? searchResults[indexPath.row] : contacts[indexPath.row]
        let contact = (searchController.isActive) ? searchResults[indexPath.row] : contactNames[indexPath.row]
        //        let contact = searchResults[indexPath.row]
        //        print(contact, contact.familyName, contact.givenName)
        let formatter = CNContactFormatter()
        
        //        cell.textLabel?.text = formatter.string(from: contact)
        cell.textLabel?.text = contact
        
        
        return cell
    }
//    func getContacts() {
//        let store = CNContactStore()
//        
//        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
//            store.requestAccess(for: .contacts, completionHandler: { (authorized: Bool, error: NSError?) -> Void in
//                if authorized {
//                    self.populateContacts()
//                }
//                } as! (Bool, Error?) -> Void)
//        } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized{
//            self.populateContacts()
//        } else if CNContactStore.authorizationStatus(for: .contacts) == .denied{
//            store.requestAccess(for: .contacts, completionHandler: { (authorized: Bool, error: NSError?) -> Void in
//                if authorized {
//                    self.populateContacts()
//                }
//                } as! (Bool, Error?) -> Void)
//        }
//    }
//    
    // AddressBook methods
    //    func retrieveAddressBookContacts(_ completion: @escaping (_ success: Bool, _ contacts: [ContactEntry]?) -> Void) {
    //        let abAuthStatus = ABAddressBookGetAuthorizationStatus()
    //        if abAuthStatus == .denied || abAuthStatus == .restricted {
    //            completion(false, nil)
    //            return
    //        }
    //
    //        let addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    //
    //        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
    //            (granted: Bool, error: CFError?) in
    //            DispatchQueue.main.async {
    //                if !granted {
    //                    self.showAlertMessage("Sorry, you have no permission for accessing the address book contacts.")
    //                } else {
    //                    var contacts = [ContactEntry]()
    //                    let abPeople = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as Array
    //                    for abPerson in abPeople {
    //                        if let contact = ContactEntry(addressBookEntry: abPerson) { contacts.append(contact) }
    //                    }
    //                    completion(true, contacts)
    //                }
    //            }
    //        }
    //    }
    
    // UITableViewDataSource && Delegate methods
    //    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        return contacts.count
    //    }
    //
    //    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
    //        let entry = contacts[(indexPath as NSIndexPath).row]
    //        cell.configureWithContactEntry(entry)
    //        cell.layoutIfNeeded()
    //
    //        return cell
    //    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var root: String?
        
        
        
        if (searchController.isActive) {
            otherPerson = searchResults[indexPath.row]
            searchController.dismiss(animated: false, completion: nil)
        } else {
            otherPerson = contactNames[indexPath.row]
        }
        
        
        
        
        
        
        //        print(selectedItem.coordinate)
        let coordinate = [String(describing: selectedItem!.coordinate)]
        
        if selectedItem!.name != nil {
            root = "Check out \(selectedItem!.name!):"
        } else {
            root = "Check out:"
        }
        
        let defaults = UserDefaults.standard
        var name = defaults.object(forKey: "Name") as! String
        let truncatedName = name.replacingOccurrences(of: " ", with: "+", options: NSString.CompareOptions.literal)
        let deeplinkURL = "placeshareapp://"
        
        let lat = String(describing: selectedItem!.coordinate.latitude)
        let long = String(describing: selectedItem!.coordinate.longitude)
        let shareString = deeplinkURL + lat + "," + long + "," + truncatedName + "," + selectedItem!.name!
        
        
        
        let vc = UIActivityViewController(activityItems: [root,shareString], applicationActivities: nil)
        //                vc.excludedActivityTypes = [UIActivityType.]
        SwiftMethods.performUIUpdatesOnMain {
            self.present(vc, animated: true, completion: nil)
        }
        //
        //
        vc.completionWithItemsHandler = { activity, success, items, error in
            //            if activity == UIActivityType.mail {
            //                let mail = UIActivityType.mail
            if (success) {
                print("shared")
                // insert save
                
                
                self.savePlace()
                
                // insert alert
                
                
                
                let alertController = UIAlertController(title: "Success", message: "Your share went through and saved to your history. Going to home screen now.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                    self.navigationController!.popToRootViewController(animated: true)
                    //                    alertController.dismiss(animated: true, completion: {
                    //
                    //                         self.navigationController!.popToRootViewController(animated: true)
                    //                    })
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
    
    //    func searchContactDataBaseOnName(name: String) {
    //        searchResults.removeAll()
    //        let predicate = CNContact.predicateForContacts(matchingName: name)
    //        //Fetch Contacts Information like givenName and familyName, phoneNo, address
    //        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactUrlAddressesKey, CNContactEmailAddressesKey]
    //        let store = CNContactStore()
    //        do {
    //            let contacts = try store.unifiedContacts(matching: predicate,
    //                                                                      keysToFetch: keysToFetch as [CNKeyDescriptor])
    //            print(contacts.count)
    //            for contact in contacts {
    //                searchResults.append(contact)
    //                print(searchResults.count)
    //            }
    //            SwiftMethods.performUIUpdatesOnMain {
    //                self.tableView.reloadData()
    //            }
    //
    //        }
    //        catch{
    //            print("Handle the error please")
    //        }
    //    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        //    let searchText = searchController.searchBar.text
        //
        //        searchResults = contactNames.filter({ (contact: String) -> Bool in
        //            //            let formatter = CNContactFormatter()
        //            //            let name = contact.givenName + " " + contact.familyName
        //
        //            let nameMatch = contact.range(of: searchText!, options: NSString.CompareOptions.caseInsensitive)
        //            //            rangeOfString(searchText,options: NSString.CompareOptions.CaseInsensitiveSearch)
        //            return nameMatch != nil
        //        })
        
        
        if let searchText = searchController.searchBar.text {
            filterControllerForSearchText(searchText: searchText)
            //            searchContactDataBaseOnName(name: searchText)
            SwiftMethods.performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
            
            
        }
        
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
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
        let idString = generateRandomNumber()
        if places.filter("id == %@", idString).first == nil {
            realm.beginWrite()
            let place = Place()
            if selectedItem!.name != nil {
                place.name = selectedItem!.name!
            } else {
                
            }
            place.id = idString
            //            place.address = "\(self.selectedItem!.thoroughfare)\n\(selectedItem!.postalCode) \(self.selectedItem!.locality)\n\(self.selectedItem!.country)"
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



