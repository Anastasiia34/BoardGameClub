//
//  GameViewController.swift
//  BoardGameClub
//
//  Created by Анастасия Стрекалова on 01.12.2021.
//

import UIKit

class GameViewController: UIViewController {
    var delegate: ClubCreationViewControllerDelegate?
    var club: Club?
    
    private var timer: Timer?
    private var timeLeft = 10
    private let buttonTapCountToWin = 30
    private var buttonTappedCount = 0 {
        didSet {
            tapCountLabel.text = "Tap count: \(buttonTappedCount)"
        }
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tapCountLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        
        if club != nil {
            label.text = "Tap the button \(buttonTapCountToWin) times in 10 secs \nto join the club"
        } else {
            label.text = "Tap the button \(buttonTapCountToWin) times in 10 secs \nto create the club"
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        animateButtonTap()
        buttonTappedCount += 1
        if buttonTappedCount >= buttonTapCountToWin {
            button.isUserInteractionEnabled = false
            guard timer != nil else {
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            timer?.invalidate()
            timer = nil
            
            if club != nil {
                let vc = storyboard.instantiateViewController(withIdentifier: "ClubJoiningViewController") as! ClubJoiningViewController
                vc.club = club
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = storyboard.instantiateViewController(withIdentifier: "ClubCreationViewController") as! ClubCreationViewController
                vc.delegate = delegate
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func animateButtonTap() {
        button.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        UIView.animate(
            withDuration: 2.0,
            delay: 0,
            usingSpringWithDamping: CGFloat(0.30),
            initialSpringVelocity: CGFloat(6.0),
            options: UIView.AnimationOptions.allowUserInteraction,
            animations: { [weak self] in
                self?.button.transform = CGAffineTransform.identity
            })

    }
    
    @objc private func onTimerFires()
    {
        timeLeft -= 1
        timeLeftLabel.text = "Time left: \(timeLeft)"
        
        if timeLeft <= 0 {
            timer?.invalidate()
            timer = nil
            if buttonTappedCount < buttonTapCountToWin {
                button.isUserInteractionEnabled = false
                let ac = UIAlertController(title: "Time out :(", message: "Try again later", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
                present(ac, animated: true)
            }
        }
    }
}
