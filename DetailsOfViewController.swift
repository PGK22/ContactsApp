//
//  DetailsViewController.swift
//  FetchContact
//
//  Created by Palak on 09/10/21.
//

import UIKit
import Contacts
protocol RefreshDataDelegate {
    func refreshDataToHomeViewController(currData : Int)
}

class DetailsOfViewController: UIViewController {
    var contactD = [FetchedContact]()
    var myIndex = 0
    var refreshDelegate: RefreshDataDelegate?
    @IBOutlet weak var namehandler: UILabel!
    
    @IBOutlet weak var telephonehandler: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Contacts"
        loadData()
    
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var emailhandler: UILabel!
    
    @IBAction func deletebutton(_ sender: Any) {
        let alert = UIAlertController(title:"Alert",message: "Are you sure you want to delete this Contact?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] action in
            self.didDeleteContact()
            FetchContact.contacts.remove(at: myIndex)
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    private func loadData() {
        if contactD.count > myIndex {
        namehandler.text = contactD[myIndex].fullName
        telephonehandler.text = contactD[myIndex].telephone
        emailhandler.text = "No Email Exist"
        }
    }
    
    @IBOutlet weak var deletebutton: UIButton!
    
    @IBAction func updatehandler(_ sender: Any) {
        let viewController = storyboard?.instantiateViewController(identifier: "SecondViewController") as! SecondViewController
        viewController.currContact? = contactD[myIndex]
        viewController.index = myIndex
        viewController.tempFirstName = contactD[myIndex].firstName
        viewController.tempLastName = contactD[myIndex].lastName
        viewController.tempTelephone = contactD[myIndex].telephone
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension DetailsOfViewController {
    
    //deletion Part
    func didDeleteContact() {
        OperationQueue().addOperation{[self,unowned store] in
            
            let predicate = CNContact.predicateForContacts(matchingName: contactD[myIndex].telephone)
            let toFetch = [CNContactGivenNameKey]
            do{
                
                let contacts = try store.unifiedContacts(matching: predicate,
                                                         keysToFetch: toFetch as [CNKeyDescriptor])
                
              
                // for the first contact matching this is done
                guard let contact = contacts.first else{
                    return
                }
                let req = CNSaveRequest()
                let mutableContact = contact.mutableCopy() as! CNMutableContact
                req.delete(mutableContact)
                do{
                    try store.execute(req)
                    print("Successfully deleted the user")
                    
                } catch let e{
                    print("Error = \(e)")
                }
                
            } catch let e{
                print("Error = \(e)")
            }
        }
        if self.refreshDelegate != nil {
            self.refreshDelegate?.refreshDataToHomeViewController(currData: myIndex)
        }
        dismiss(animated: true, completion: nil)
    }
}


