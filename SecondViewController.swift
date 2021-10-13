//
//  SecondViewController.swift
//  FetchContact
//
//  Created by Palak on 08/10/21.
//

import UIKit
import Contacts
protocol MyDataSendingProtocol {
    func sendDataToHomeViewController(myData:FetchedContact)
    
}

class SecondViewController: UIViewController,UITextFieldDelegate {
    var delegate : MyDataSendingProtocol? = nil
    lazy var currContact : FetchedContact? = nil
    var index = 0
    var tempFirstName : String = ""
    var tempLastName : String = ""
    var tempTelephone : String = ""
    var isUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Contacts"
        firstName.addTarget(self, action:#selector(willCheckAndDisplayErrorsForName(firstName:)), for: .editingChanged)
        lastName.addTarget(self, action:#selector(willCheckAndDisplayErrorsForName2(lastName:)), for: .editingChanged)
        telephoneLabel.delegate = self
        
        updateLabels()
        // Do any additional setup after loading the view.
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        // OR with Tag like textfield.tag == 45
        if textField == telephoneLabel {
            if validate(value: telephoneLabel.text ?? " ") {
                errorLabel.text = ""
            }
            else {
                errorLabel.text = "Enter numbers only"
            }
        }
    }
    func validate(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result = phoneTest.evaluate(with: value)
        return result
    }
    
    
    @objc func willCheckAndDisplayErrorsForName(firstName : UITextField){
        if firstName.text?.count ?? 0 < 3 {
            errorLabel.text = "First Name missing .Pls Add a Valid first Name"
        }else {
            errorLabel.text = " "
        }
    }
    @objc func willCheckAndDisplayErrorsForName2(lastName : UITextField){
        if lastName.text?.count ?? 0 < 3 {
            errorLabel.text = "Last Name missing .Pls Add a Valid last Name"
        }else {
            errorLabel.text = " "
        }
    }
    
    
    
    
    
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var firstName: UITextField!
    
    @IBOutlet weak var lastName: UITextField!
    
    
    @IBAction func saveContact(_ sender: Any) {
        if isUpdate {
            didUpdateContacts()
        }
        else{
            didStoreData()
        }
    }
    @IBOutlet weak var telephoneLabel: UITextField!
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}
extension SecondViewController{
    private func didStoreData() {
        let newContact = CNMutableContact()
        newContact.givenName = firstName.text ?? ""
        newContact.familyName = lastName.text ?? ""
        
        let homePhone = CNLabeledValue(label: CNLabelHome,
                                       value: CNPhoneNumber(stringValue: telephoneLabel.text ?? ""))
        newContact.phoneNumbers = [homePhone]
        newContact.note = "This contact is added by third-party app"
        
        let request = CNSaveRequest()
        request.add(newContact, toContainerWithIdentifier: nil)
        do{
            try store.execute(request)
            //addContactInCache()
            print("Successfully stored the contact")
        } catch let err{
            print("Failed to save the contact. \(err)")
        }
        if self.delegate != nil {
            let tempFullName =  (firstName.text ?? "") + " " + (lastName.text ?? "")
            let currentContact = FetchedContact(firstName: firstName.text ?? "", lastName: lastName.text ?? "", fullName: tempFullName, telephone: telephoneLabel.text ?? "")
            self.delegate?.sendDataToHomeViewController(myData: currentContact)
        }
        didShowSuccessAlert()
    }
    private func didShowSuccessAlert() {
        let alert = UIAlertController(title: "Alert", message: "Contact saved Successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func didShowError() {
        let alert = UIAlertController(title: "Alert", message: "Contact coudn't be added, Validation failed!!", preferredStyle: .alert)
        print("Invalid Details Entered")
    }
    
    
    func updateLabels(){
        firstName.text = tempFirstName
        lastName.text = tempLastName
        telephoneLabel.text = tempTelephone
        isUpdate = true
    }
    
    func didUpdateContacts() {
        didDeleteContact()
        FetchContact.contacts.remove(at: index)
        didStoreData()
    }
    
    
    
    
    //deletion Part
    func didDeleteContact() {
        OperationQueue().addOperation{[self,unowned store] in
            guard let searchPred = currContact?.telephone else {
                debugPrint("Error while updating")
                return
            }
            let predicate = CNContact.predicateForContacts(matchingName: searchPred)
            let toFetch = [CNContactGivenNameKey]
            do{
                
                let contacts = try store.unifiedContacts(matching: predicate,
                                                         keysToFetch: toFetch as [CNKeyDescriptor])
                
                guard contacts.count > 0 else{
                    print("No contacts found")
                    return
                }
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
    }
}


