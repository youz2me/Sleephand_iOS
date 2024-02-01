//
//  ConnectBLEVC.swift
//  ControlMusicToSleep
//
//  Created by YOUJIM on 2/1/24.
//

import CoreBluetooth
import MediaPlayer
import UIKit

import SnapKit
import Then

class ConnectBLEVC: UIViewController {
    
    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    
    private var backgroundImageView: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "ConnectBackground")
        $0.contentMode = .scaleAspectFill
    }
    
    private var BLETableView: UITableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.register(BLETableViewCell.self, forCellReuseIdentifier: BLETableViewCell().cellID)
    }
    
    private var peripherals: [CBPeripheral] = []
    private var centralManager: CBCentralManager!
    private var connectedBLE: CBPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        view.addSubview(backgroundImageView)
        view.addSubview(BLETableView)
        
        BLETableView.dataSource = self
        BLETableView.delegate = self
        
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        BLETableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(162)
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview()
        }
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        if(!centralManager.isScanning) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("스캔 시작")
                self.centralManager?.scanForPeripherals(withServices: [CBUUID(string: "FEE0")])
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.centralManager.stopScan()
                    print("스캔 끝")
                }
            }
        }
    }
}

extension ConnectBLEVC : CBPeripheralDelegate, CBCentralManagerDelegate {
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
        let check: Bool = false
        if !check {
            peripherals.append(peripheral)
            
            BLETableView.reloadData()
        }
    }
    
    // 기기 연결가 연결되면 호출되는 메서드입니다.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("연결 성공: \(peripheral.name!)")
        peripheral.delegate = self
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print("didUpdateValueFor")
        
        if musicPlayer.playbackState == .playing {
            musicPlayer.stop()
        }
        else {
            musicPlayer.play()
        }
    }
    
    // characteristic 검색에 성공 시 호출되는 메서드입니다.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("dmdkdkdkdk")
    }
    
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

extension ConnectBLEVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BLETableViewCell().cellID, for: indexPath) as! BLETableViewCell
        
        let peripheralName = peripherals[indexPath.row].name
        cell.BLENameLabel.text = peripheralName

        cell.backgroundColor = .clear
        

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// 테이블 뷰의 셀을 선택했을 때 UI에 나타나는 효과
        tableView.deselectRow(at: indexPath, animated: true)
        
        centralManager.stopScan()
        
        centralManager.connect(peripherals[indexPath.row])
        
        let sleepingVC = SleepingVC()
        
        sleepingVC.modalTransitionStyle = .crossDissolve
        sleepingVC.modalPresentationStyle = .fullScreen
        
        self.present(sleepingVC, animated: true)
    }
}
