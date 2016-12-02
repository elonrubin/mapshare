//
//  ViewController.swift
//  Map Share
//
//  Created by Elon Rubin on 11/30/16.
//  Copyright © 2016 Elon Rubin. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //--------------------------------------
    // MARK: Variables
    //--------------------------------------
    // Realm Variables
    
    let realm = try! Realm()
    lazy var places: Results<Place> = { self.realm.objects(Place.self)  }()
    var place: Place = Place()
    var didRecievePlaceShare: Bool?
    
    //--------------------------------------
    // MARK: Outlets
    //--------------------------------------
    @IBOutlet var nameTextFieldOne: UITextField!
    
    @IBOutlet var nameTextFieldTwo: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //--------------------------------------
    // MARK: View Controller Functions
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
      // This function checks whether a user has entered their name and it saved into NSUserDefaults. If false, it prompts user to enter name. If true, it loads saved places
        hasUserEnteredName ()
        // If you are on a simulator, download Realm Browser (http://tinyurl.com/j8q9p2e) and enter url to see database.
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // When someone taps on a tablecell, it calls this segue. This passes place information to map view controller
        if segue.identifier == "homeToDetailViewSegue" {
            let vc = segue.destination as! MapViewController
            vc.place = place
        }
    }
    
    //--------------------------------------
    // MARK: Functions/Actions
    //--------------------------------------
    
    // Table Implementation - Number of Rows, Cell For Row, Did Select Row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var summaryLabel = ""
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let place = places[indexPath.row]
        
        // This is logic to tell whether a place objcet is a sent or recieved item.
        if place.sent == false {
            summaryLabel = " (Recieved from \(place.otherName))"
        } else {
            summaryLabel = " (Sent to \(place.otherName))"
        }
        
        cell.textLabel!.text = place.name + summaryLabel
        cell.detailTextLabel?.text = place.address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        place = places[indexPath.row]
        self.performSegue(withIdentifier: "homeToDetailViewSegue", sender: self)
    }
    
    @IBAction func shareNewPlaceButtonPushed(_ sender: Any) {
        // this is a segue to ShareInfoViewController
        self.performSegue(withIdentifier: "choose place", sender: self)
    }
    
    
    //--------------------------------------
    // MARK: Alterview/Textfield Configuration and Handler
    //--------------------------------------
    
    func addTextFieldOne(textField: UITextField!){
        // add the text field and make the result global
        textField.placeholder = "Enter First and Last Name"
        self.nameTextFieldOne = textField
    }
    
    func addTextFieldTwo(textField: UITextField!){
        // add the text field and make the result global
        textField.placeholder = "Confirm First and Last Name"
        self.nameTextFieldTwo = textField
    }
    
    
    func presentNameAlertController () {
        let alertController = UIAlertController(title: "Enter First and Last Name", message: "You must enter your first and last name to continue", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: addTextFieldOne)
        
        alertController.addTextField(configurationHandler: addTextFieldTwo)
        
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: wordEntered))
        
        DispatchQueue.main.async(execute: {
            self.present(alertController, animated: true, completion: nil)
        })
        
    }
    

    
    func wordEntered(alert: UIAlertAction!){
        // store the new word
        //        print(emailTextFieldOne.text!, emailTextFieldTwo.text!)
        if nameTextFieldOne.text! == nameTextFieldTwo.text! {
           let defaults = UserDefaults.standard
            defaults.set(nameTextFieldOne.text!, forKey: "Name")
            defaults.set(true, forKey: "hasUserEnteredName")
           self.tableView.reloadData()
        
        } else {
            let alertController = UIAlertController(title: "Enter name again", message: "Your entries didn't match. Please enter again", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                
                alertController.dismiss(animated: false, completion: nil)
                self.presentNameAlertController()
                
            }
            
            alertController.addAction(okAction)
            
            
            DispatchQueue.main.async(execute: {
                self.present(alertController, animated: true, completion: nil)
            })
            
        }
    }
    
    func hasUserEnteredName () {
        let defaults = UserDefaults.standard
        let hasUserEnteredName = defaults.bool(forKey: "hasUserEnteredName")
        
        if hasUserEnteredName == false {
            presentNameAlertController()
            
        } else {
            self.tableView.reloadData()
        }
        
    }

    
}

