//
//  BluetoothSerial.swift
//  ControlMusicToSleep
//
//  Created by YOUJIM on 2/1/24.
//

import UIKit
import CoreBluetooth


// MARK: 블루투스와 관련된 일을 전담하는 글로벌 시리얼 핸들러

var serial: BluetoothSerial!

class BluetoothSerial: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var delegate : BluetoothSerialDelegate? // BluetoothSerialDelegate 프로토콜에 등록된 메서드를 수행하는 delegate
    var centralManager: CBCentralManager! // 주변 기기 검색 및 연결
    var pendingPeripheral: CBPeripheral? // 현재 연결을 시도하는 블루투스 주변 기기
    var connectedPeripheral: CBPeripheral? // 연결에 성공한 기기
    weak var writeCharacteristic: CBCharacteristic? // 데이터를 보내기 위한 characteristic을 저장하는 변수
    private var writeType: CBCharacteristicWriteType = .withoutResponse // 데이터를 주변 기기에 보내는 타입
    var serviceUUID = CBUUID(string: "FFE0") // Peripheral이 가지고 있는 서비스의 UUID
    var characteristicUUID = CBUUID(string : "FFE1") // 데이터 송수신을 위한 characteristicUUID
    
    
    // MARK: Serial을 초기화할 떄 호출함
    /// 시리얼은 nil이여서는 안되기 때문에 항상 초기화한 후 사용해야 함
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    
    // MARK: 기기 검색을 위한 함수
    /// 연결 가능한 모든 주변 기기를 serviceUUID를 통해 찾아냄
    
    func startScan() {
        guard centralManager.state == .poweredOn else {
            return }
        
        print("스캔 시작스")
        
        /// CBCentralManager의 메서드인 scanForPeripherals를 호출하여 연결가능한 기기들을 검색함.
        /// 이 때 withService 파라미터에 nil을 입력하면 모든 종류의 기기가 검색되고, 지금과 같이 serviceUUID를 입력하면 특정 serviceUUID를 가진 기기만을 검색합니다.
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        
        let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [serviceUUID])
        for peripheral in peripherals {
            /// 검색된 기기들에 대한 처리
            print("처리중")
            delegate?.serialDidDiscoverPeripheral(peripheral: peripheral, RSSI: nil)
        }
    }
    
    
    // MARK: 기기 검색을 중단하는 함수
    
    func stopScan() {
        centralManager.stopScan()
    }
    
    
    // MARK: 파라미터로 넘어온 주변 기기를 CentralManager에 연결하도록 시도하는 함수
    
    func connectToPeripheral(_ peripheral : CBPeripheral)
    {
        // 연결 실패를 대비하여 현재 연결 중인 주변 기기를 저장합니다.
        pendingPeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    
    // MARK: central 기기의 블루투스의 켜짐 상태를 확인하는 함수
    /// 확인하여 centralManager.state의 값을 .powerOn 또는 .powerOff로 변경함
    /// CBCentralManagerDelegate에 포함되어 있는 메서드

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        pendingPeripheral = nil
        connectedPeripheral = nil
    }
    
    // MARK: 기기가 검색될 때마다 호출되는 함수
    /// RSSI는 기기의 신호 강도를 의미함
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        delegate?.serialDidDiscoverPeripheral(peripheral: peripheral, RSSI: RSSI)
    }
    
    
    // MARK: 기기가 연결되면 호출되는 함수
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        pendingPeripheral = nil
        connectedPeripheral = peripheral
        
        /// peripheral의 Service들을 검색함
        /// 파라미터를 nil으로 설정하면 peripheral의 모든 service를 검색함
        peripheral.discoverServices([serviceUUID])
    }
    
    
    // MARK: service 검색에 성공 시 호출되는 함수
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            /// 검색된 모든 service에 대해서 characteristic을 검색함
            ///파라미터를 nil로 설정하면 해당 service의 모든 characteristic을 검색함
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    
    // MARK: characteristic 검색에 성공 시 호출되는 함수
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            /// 검색된 모든 characteristic에 대해 characteristicUUID를 한번 더 체크하고, 일치한다면 peripheral을 구독하고 통신을 위한 설정을 완료힘
            if characteristic.uuid == characteristicUUID {
                /// 해당 기기의 데이터를 구독함
                peripheral.setNotifyValue(true, for: characteristic)
                /// 데이터를 보내기 위한 characteristic을 저장함
                writeCharacteristic = characteristic
                /// 데이터를 보내는 타입을 설정함
                /// 이는 주변기기가 어떤 type으로 설정되어 있는지에 따라 변경됨
                writeType = characteristic.properties.contains(.write) ? .withResponse :  .withoutResponse
                
                /// 주변 기기와 연결 완료 시 동작하는 코드
                delegate?.serialDidConnectPeripheral(peripheral: peripheral)
            }
        }
    }
    
    
    // MARK: writeType이 .withResponse일 때, 블루투스 기기로부터의 응답이 왔을 때 호출되는 함수
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        // writeType이 .withResponse인 블루투스 기기로부터 응답이 왔을 때 필요한 코드를 작성함
        
    }
    
    
    // MARK: 블루투스 기기의 신호 강도를 요청하는 peripheral.readRSSI()가 호출하는 함수
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        // 신호 강도와 관련된 코드를 작성함
    }
}


// MARK: 블루투스를 연결하는 과정에서의 시리얼과 뷰의 소통을 위해 필요한 프로토콜

protocol BluetoothSerialDelegate : AnyObject {
    /// Peripheral이 발견되었을 때 검색된 기기 리스트와 테이블 뷰를 업데이트하는 메서드
    func serialDidDiscoverPeripheral(peripheral : CBPeripheral, RSSI : NSNumber?)
    /// Peripheral이 연결되었을 때 호출되는 메서드
    func serialDidConnectPeripheral(peripheral : CBPeripheral)
}


// MARK: 프로토콜에 포함되어 있는 일부 함수를 옵셔널로 설정

extension BluetoothSerialDelegate {
    func serialDidDiscoverPeripheral(peripheral : CBPeripheral, RSSI : NSNumber?) {}
    func serialDidConnectPeripheral(peripheral : CBPeripheral) {}
}
