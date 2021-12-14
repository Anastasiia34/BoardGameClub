//
//  ClubJoiningViewController.swift
//  BoardGameClub
//
//  Created by Анастасия Стрекалова on 01.12.2021.
//

import UIKit

class ClubJoiningViewController: UIViewController {
    var club: Club?
    
    @IBOutlet weak var clubNameLabel: UILabel!
    @IBOutlet weak var creatorNicknameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        clubNameLabel.text = "Club name: \(club?.name ?? "")"
        creatorNicknameLabel.text = "Creator's nickname: \(club?.creatorName ?? "")"
    }

    @IBAction func joinButtonTapped(_ sender: Any) {
        guard let url = club?.url else {
            return
        }
        
        UIApplication.shared.open(url)
    }
}
