//
//  ConnectBLEVC.swift
//  ControlMusicToSleep
//
//  Created by YOUJIM on 2/1/24.
//

import CoreBluetooth
import UIKit

import SnapKit
import Then

class ConnectBLEVC: UIViewController, BluetoothSerialDelegate {
    
    private var backgroundImageView: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "ConnectBackground")
        $0.contentMode = .scaleAspectFill
    }
    
    private var BLETableView: UITableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.register(BLETableViewCell.self, forCellReuseIdentifier: BLETableViewCell().cellID)
    }
    
    // 현재 검색된 peripheralList
    private var peripheralList : [(peripheral : CBPeripheral, RSSI : Float)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        view.addSubview(backgroundImageView)
        view.addSubview(BLETableView)
        
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        BLETableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(162)
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview()
        }
        
        serial = BluetoothSerial.init()
        serial.delegate = self
        serial.startScan()
        print("스캔 시작")
    }
    
    func serialDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber?) {
        /// serial의 delegate에서 호출됨
        /// 이미 저장되어 있는 기기라면 return
        for existing in peripheralList {
            if existing.peripheral.identifier == peripheral.identifier {return}
        }
        
        /// 신호의 세기에 따라 정렬
        let fRSSI = RSSI?.floatValue ?? 0.0
        peripheralList.append((peripheral : peripheral , RSSI : fRSSI))
        peripheralList.sort { $0.RSSI < $1.RSSI}
        
        /// tableView를 다시 호출하여 검색된 기기가 반영되도록 함
        DispatchQueue.main.async {
            print("tableView를 다시 호출")
            self.BLETableView.reloadData()
        }
    }
    
    func serialDidConnectPeripheral(peripheral: CBPeripheral) {
        /// serial의 delegate에서 호출됨
        /// 연결 성공 시 alert를 띄우고, alert 확인 시 View를 dismiss
        let connectSuccessAlert = UIAlertController(title: "블루투스 연결 성공", message: "\(peripheral.name ?? "알수없는기기")와 성공적으로 연결되었습니다.", preferredStyle: .actionSheet)
        let confirm = UIAlertAction(title: "확인", style: .default, handler: { _ in self.dismiss(animated: true, completion: nil) } )
        
        connectSuccessAlert.addAction(confirm)
        
        serial.delegate = nil
        
        present(connectSuccessAlert, animated: true, completion: nil)
    }
}

extension ConnectBLEVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BLETableViewCell().cellID, for: indexPath) as! BLETableViewCell
        
        if let peripheralName = peripheralList[indexPath.row].peripheral.name {
            cell.BLENameLabel.text = peripheralName
        }

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// 테이블 뷰의 셀을 선택했을 때 UI에 나타나는 효과
        tableView.deselectRow(at: indexPath, animated: true)
        
        /// 선택된 Pheripheral을 연결함
        /// 검색을 중단하고, peripheralList에 저장된 peripheral 중 클릭된 것을 찾아 연결함
        serial.stopScan()
        
        let selectedPeripheral = peripheralList[indexPath.row].peripheral
        
        /// serial의 connectToPeripheral 함수에 선택된 peripheral을 연결하도록 요청함
        serial.connectToPeripheral(selectedPeripheral)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
