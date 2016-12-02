//
//  ShareInfoViewController.swift
//  Map Share
//
//  Created by Elon Rubin on 11/30/16.
//  Copyright © 2016 Elon Rubin. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import ContactsUI


@available(iOS 9.0, *)
class ShareInfoViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, CNContactPickerDelegate {

    //--------------------------------------
    // MARK: Variables
    //--------------------------------------
    
    // Search and Location Variables
    let searchController = UISearchController(searchResultsController: nil)
    var locationAddress : String! = nil
    var matchingItems:[MKMapItem] = []
    var locationCoordinate: CLLocationCoordinate2D?
    var selectedItem: MKPlacemark?
    weak open var delegate: UISearchControllerDelegate?
    weak open var pickerdelegate: CNContactPickerDelegate?
    
        let contactPickerViewController = CNContactPickerViewController()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
// I instantiate a search controller programmatically and embed the search bar on the tableheading top
//BUG - first responder isn't working.
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar

        self.searchController.searchBar.becomeFirstResponder()
        contactPickerViewController.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //--------------------------------------
    // MARK: Autocomplete Place Search Result Implementation
    //--------------------------------------
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            SwiftMethods.performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return matchingItems.count
    }
    
    
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
    let selectedItem = matchingItems[indexPath.row].placemark
    
    cell.textLabel?.text = selectedItem.name
    cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
    return cell
    
    
    }
    
    // When a user taps on a cell, it takes the selectedItem MKPLacemark Object and passes it to the ContactViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedItem = matchingItems[indexPath.row].placemark
        
      self.performSegue(withIdentifier: "addressToContactSegue", sender: self)
        
              }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addressToContactSegue" {
            let vc = segue.destination as! ContactViewController
            vc.selectedItem = selectedItem!
        }
    }
    
    
    @IBAction func cancelBtnPushed(_ sender: Any) {
        navigationController!.popViewController(animated: true)
    }
    
    
    
}
