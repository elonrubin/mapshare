# Placeshare Notes

## Important - Install Realm Cocoapod Prior To Using
* See pod.file.
* This is written in Swift 3 and uses Xcode 8.1
* This is compatible with iOS 9.0 and above (I explain my reasoning below)

## Main Screen
  * When you first open the app, I prompt the user to give their first and last name. I have a function that checks whether a bool was set for the user adding their name and it saving to NSUserDefaults. 
  * The main action is the Share New Place button on the bottom of the main screen. 
    When you tap on this button, it segues to a place lookup controller. 
*  ### To Do
    * Add code to make segmentview operational 
*   ### Enhancements
   * Add more sorting abilities 
   * I would probably subclass UITableViewCell and enhance the information presented on a cell and the layout of information
## Place Lookup Controller
   * This is equiavalent to google’s autocomplete, it uses MapKit and a completion handler called MKLocalSearchRequest that conforms to the UISearchResultsUpdating protocol
   * Once a user taps on a place, it then directs to a ContectViewController. I save the MKPlacemark to a global variable within the controller, then pass that variable in PrepareForSegue metho
*   ###Enhancements
    * I would add more direction in the search prompt. 
    * I would add an alert view tied to a NSUserDefault briefly explaining how to look up places
    * Searchcontroller was responding weirdly to becomefirstresponder() command. I typically like the keyboard to popup when at a search screen. It saves a tap. 
*   ###Bug fix
    *If you do three or four searches, you have to tap cancel and tap on the Add Place Button again
  
##Contact Lookup Controller
   * It uses ContactsUI. You can either scroll down or search by name in the search bar above. When you tap, it brings up a UIActivityAlertViewController. You can share via message, email, Facebook and the other types of ActivityTypeDefaults
    * This actually took more time because I couldn’t use the Apple view controller and functionality for displaying contacts. The reason is that customizing actions take a bit of work because Apple’s delegate methods are sometimes hard to follow and a bit buggy. I wanted the action of tapping on a contact, and then adding the UIActivityController subview. 
    * To enable deep linking, I point to the URL scheme created in the App Share target and add the longitude, latitude and the users name to the handle. When tapped on, the information is handled by a method in the AppDelegate file that corresponds to deep linking 
    * I implemented UISearchResultsUpdating 
    * I have a method that checks for whether something was shared. If it is, I save it to Realm, a lightweight core data replacement installed via cocoa pod, Then an alert view appears, saying the item has been saved and seguing back to the Root View Controller 
 *  ###To Do
    * I need to add code to segue to PlaceDetailViewController
    * I need to save this place and associated data
    * Need to add code that handles if a user didn’t share the item
    * To get address information, I utilize a lot of the properties of the MKPlacemark object. All the information is optionals. I need to add if let logic coupled with a little bit more logic to ensure that nonexistent information is not saved (and doesn’t cause fatal crashes). 
  ###Enhancements
    * Replace UIActivityView with UIActivitySheet and utilize email and mobile number information to prefill share fields
    * Add sections 
    * Add scroll index
  ###Bugs
    *When you tap on what to share, it clears the search bar and results to the default datasource 
    
##Place Detail Controller
    * If you tap on a tableviewcell on the main screen, it segues to the MapViewController. I pass a Place object - which is a subclass of NSObject, and Realm specific - to the map view
    * The mapview shows a pin with the name and address. A user can zoom in and can also use 3d features 
    * You press done to pop the view controller and go back to the main screen
  ###Performance Issues/Bugs
    *The map is a bit sluggish to load. In my experience, I have found some performance bugs in apple’s map framework that can be optimized through testing and tweaking code. 
  ###To Do
* I need to make the share button on the navigation bar work 
 *  ### Enhancements
    * * I would consider adding a field saying who shared it

##Other notes
  * ### Backwards compatibility 
    * * Adding compatibility with iOS 8 and prior will take a bit more work
*     * Address Book Changes
*     *  iOS 9+ uses Contact framework, whereas older versions use an address kit framework. The latter is much more antiquated than the former. You would need to add a bool/logic statements to render the information differently per os version. 
  * ###   Deep Linking
      * A second issue - and something you should consider in your specs - is deep linking ability in os prior to 9. It appears to me that the deep linking scheme in iOS 9/10 does not exist in prior oss. I believe you have to register a link scheme with your developer account, something similar to Push notifications. 
  *   ### Low Adoption Prior To iOS 9
      * Finally, around 4-6% of active devices appear to have iOS 8. 
    * Notwithstanding the specs of this assignment (if this were a real project), I would probably suggest having a team discussion on the merits of having iOS 8 and lower compatibility.. And in the context of this assignment, I really don’t think it’s worth doing because of this looming question. 
*   ###Core Data
    *I typically use Realm to replace CoreData. I do this because it is a lot easier to sort and handle data, and I also believe there’s a performance increase
  ##User Interface
    * I would obviously work on spiffing up the UI, and perhaps animations and other enhancements. I don’t think it’s needed for this assignment. 

