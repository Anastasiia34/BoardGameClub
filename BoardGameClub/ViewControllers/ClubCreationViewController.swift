//
//  ClubCreationViewControllerDelegate.swift
//  BoardGameClub
//
//  Created by Анастасия Стрекалова on 01.12.2021.
//

import MapKit
import UIKit

protocol ClubCreationViewControllerDelegate {
    func clubCreated(url: URL, clubName: String, creatorName: String)
}

class ClubCreationViewController: UIViewController, UITextFieldDelegate {
    var delegate: ClubCreationViewControllerDelegate?
    
    @IBOutlet weak var clubNameTextfield: UITextField!
    @IBOutlet weak var creatorNameTextfield: UITextField!
    @IBOutlet weak var clubUrlTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clubNameTextfield.delegate = self
        creatorNameTextfield.delegate = self
        clubUrlTextfield.delegate = self
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
        guard
            let clubNameText = clubNameTextfield.text,
            !clubNameText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty,
            let creatorNameText = creatorNameTextfield.text,
            !creatorNameText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty,
            let clubUrlText = clubUrlTextfield.text,
            !clubUrlText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
        else {
            showAlert(title: "Some fields are empty", message: "Please fill them in")
            return
        }
        
        guard
            clubUrlText.hasPrefix("https://t.me/") || clubUrlText.hasPrefix("https://chat.whatsapp.com/") || clubUrlText.hasPrefix("https://invite.viber.com/"),
            let url = URL(string: clubUrlText),
            UIApplication.shared.canOpenURL(url)
        else {
            showAlert(title: "Invalid url", message: "Try again")
            return
        }
        
        delegate?.clubCreated(url: url, clubName: clubNameText, creatorName: creatorNameText)
    }
    
    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(ac, animated: true)
    }
}
