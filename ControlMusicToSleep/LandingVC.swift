//
//  ViewController.swift
//  ControlMusicToSleep
//
//  Created by YOUJIM on 1/31/24.
//

import UIKit
import CoreBluetooth

class LandingVC: UIViewController {
    
    private var backgroundImageView: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "LandingBackground")
        $0.contentMode = .scaleAspectFit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(backgroundImageView)
        
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let connectVC = ConnectBLEVC()
            connectVC.modalPresentationStyle = .fullScreen
            connectVC.modalTransitionStyle = .crossDissolve
            
            self.present(connectVC, animated: true)
        }
    }
}
