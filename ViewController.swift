//
//  ViewController.swift
//  FetchContact
//
//  Created by Palak on 07/10/21.
//

import UIKit
import Contacts

// FetchedContact is Structure in the file FetchedContact.swift File

var contacts : [FetchedContact] = []
let store = CNContactStore()



class ViewController: UIViewController {
    
    @IBOutlet weak var contactTable: UICollectionView!
    
    private let imageView : UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        imageView.image = UIImage(named: "Image")
        return imageView
    }()
    
    @IBAction func AddContact(_ sender: Any) {
        print("Clicked")
        performSegue(withIdentifier: "backsegue", sender: nil)
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    // Adding Segue Code
    override func prepare(for segue:UIStoryboardSegue, sender: Any?){
        if segue.identifier=="forwardsegue"{
            let secondVC: DetailsOfViewController =  segue.destination as! DetailsOfViewController
            secondVC.refreshDelegate = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contact App"
        tableView.register(UINib(nibName: "ContactViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.reloadData()
        fetchContacts()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
}

// Do any additional setup after loading the view.
// requestContacts()

/*
 @IBAction func btn_SaveClick(_ sender: UIButton) {
 let secondVC = self.storyboard?.instantiateViewController(identifier: "second") as! SecondViewController
 secondVC.delegate = self
 self.navigationController?.pushViewController((secondVC), animated: true)
 }
 func dataPassing(number: String) {
 lblContact.text = number
 }
 */

/*
 
 
 
 func retrieveContacts(from store: CNContactStore) {
 let containerID=store.defaultContainerIdentifier()
 let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerID)
 let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor,CNContactImageDataKey as CNKeyDescriptor]
 do {
 contacts=try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
 
 print(contacts)
 print("Printed Successfully")
 }
 catch{
 print("Something went wrong")
 }
 }
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 return contacts.count;
 }
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 let contact = contacts[indexPath.row]
 let cell = UITableViewCell()
 cell.textLabel?.text = contact.familyName
 return cell
 
 
 }
 */
extension ViewController : MyDataSendingProtocol {
    func sendDataToHomeViewController(myData: FetchedContact) {
        print("Added Data Here")
        contacts.append(myData)
        
    }
}
extension ViewController : RefreshDataDelegate {
    func refreshDataToHomeViewController(currData: Int) {
        contacts.remove(at : currData)
        
    }
}
// Fetch the Contacts
func fetchContacts(){
    let store=CNContactStore()
    store.requestAccess(for: .contacts){(granted,error) in
        if let error=error{
            print("Failed to load the Contact Request",error)
            return
        }
        if(granted){
            let keys=[CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey,CNContactImageDataKey]
            let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
            do {
                // 3.
                try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in contacts.append(FetchContact.FetchedContact(firstName: contact.givenName, lastName: contact.familyName, fullName: contact.givenName + " " + contact.familyName  , telephone: contact.phoneNumbers.first?.value.stringValue ?? ""))
                    print("Contacts Fetched Properly!!")
                    print(contacts)
                    
                })
                
            } catch let error {
                print("Failed to enumerate the  contact", error)
            }
        } else {
            print("Sorry access denied")
        }
        
    }
}



//Custom TableView Layout
extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Heres contact Count!!")
        print(contacts.count)
        return contacts.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if  indexPath.row < contacts.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactViewCell
            cell.namehandler?.text = contacts[indexPath.row].firstName + " " + contacts[indexPath.row].lastName
            cell.telephonehandler?.text = contacts[indexPath.row].telephone
            
            print("The Cell is here")
            print(cell)
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(identifier: "DetailsOfViewController") as! DetailsOfViewController
        viewController.contactD = contacts
        viewController.myIndex = indexPath.row
        navigationController?.pushViewController(viewController, animated: true)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteCell = initDeleteAction(at : indexPath)
        return UISwipeActionsConfiguration(actions: [deleteCell])
    }
    
    func initDeleteAction(at indexPath : IndexPath)->UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") {
            (action, view, completion) in
            contacts.remove(at : indexPath.row)
            print("Item Deleted")
            self.tableView.deleteRows(at : [indexPath], with : .automatic)
            completion(true)
            
            
        }
        return action
    }
}
