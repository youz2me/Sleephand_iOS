//
//  SleepingVC.swift
//  ControlMusicToSleep
//
//  Created by YOUJIM on 2/1/24.
//

import CoreBluetooth
import MediaPlayer
import UIKit

import SnapKit
import Then

class SleepingVC: UIViewController {
    
    private var backgroundImageView: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "SleepingBackground")
        $0.contentMode = .scaleAspectFill
    }
    
    private var stopButton: UIButton = UIButton().then {
        $0.setTitle("기기 연결 중단하기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(hexCode: "3B46AC")
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 28
        //$0.addTarget(self, action: , for: <#T##UIControl.Event#>)
    }
    
    private var centralManager: CBCentralManager!
    
    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        view.backgroundColor = .black
        
        view.addSubview(backgroundImageView)
        view.addSubview(stopButton)
        
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        stopButton.snp.makeConstraints {
            $0.width.equalTo(242)
            $0.height.equalTo(55)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview().offset(-203)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.musicPlayer.stop()
        }
    }
}


extension SleepingVC : CBPeripheralDelegate, CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("unknown")
        case .resetting:
            print("restting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("power Off")
        case .poweredOn:
            print("power on")
        @unknown default:
            fatalError()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
    }
    
    // 기기 연결가 연결되면 호출되는 메서드입니다.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
    }
    
    // characteristic 검색에 성공 시 호출되는 메서드입니다.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

    }
    
    // writeType이 .withResponse일 때, 블루투스 기기로부터의 응답이 왔을 때 호출되는 함수입니다.
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didWriteValueFor")
        
        if musicPlayer.playbackState == .playing {
            musicPlayer.stop()
        }
        else {
            musicPlayer.play()
        }
    }
    
    // 블루투스 기기의 신호 강도를 요청하는 peripheral.readRSSI()가 호출하는 함수입니다.
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        // 신호 강도와 관련된 코드를 작성합니다.(필요하다면 작성해주세요.)
    }
    
    // peripheral으로부터 데이터를 전송받으면 호출되는 메서드입니다.
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueFor")
        
        if musicPlayer.playbackState == .playing {
            musicPlayer.stop()
        }
        else {
            musicPlayer.play()
        }
    }
}


// MARK: hexCode로 색상 설정 가능하게 하는 extension

extension UIColor {
    
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}
