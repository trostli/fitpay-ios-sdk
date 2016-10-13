import CoreBluetooth

internal class BluetoothPaymentDeviceConnector : NSObject, IPaymentDeviceConnector {
    weak var paymentDevice : PaymentDevice!
    
    var centralManager : CBCentralManager?
    var wearablePeripheral : CBPeripheral?
    var lastState : CBCentralManagerState = CBCentralManagerState.poweredOff
    
    var continuationCharacteristicControl: CBCharacteristic?
    var continuationCharacteristicPacket: CBCharacteristic?
    var apduControlCharacteristic: CBCharacteristic?
    var securityWriteCharacteristic: CBCharacteristic?
    var deviceControlCharacteristic: CBCharacteristic?
    var applicationControlCharacteristic: CBCharacteristic?
    var notificationCharacteristic: CBCharacteristic?
    
    var continuation : Continuation = Continuation()
    var deviceInfoCollector : BLEDeviceInfoCollector?
    
    fileprivate var _deviceInfo : DeviceInfo?
    fileprivate var _nfcState : SecurityNFCState?
    
    let maxPacketSize : Int = 20
    let apduSecsTimeout : Double = 5
    var sequenceId: UInt16 = 0
    var sendingAPDU : Bool = false
    
    var timeoutTimer : Timer?
    
    required init(paymentDevice device: PaymentDevice) {
        self.paymentDevice = device
    }
    
    func connect() {
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        if lastState == CBCentralManagerState.poweredOn {
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func disconnect() {
        resetToDefaultState()
        
        self.paymentDevice?.callCompletionForEvent(PaymentDeviceEventTypes.onDeviceDisconnected)
        self.paymentDevice?.connectionState = ConnectionState.disconnected
    }
    
    func resetToDefaultState() {
        if let wearablePeripheral = self.wearablePeripheral {
            centralManager?.cancelPeripheralConnection(wearablePeripheral)
            
            wearablePeripheral.delegate = nil
        }
        
        centralManager?.stopScan()
        centralManager?.delegate = nil
        centralManager = nil
        _deviceInfo = nil
        sequenceId = 0
        sendingAPDU = false
        deviceInfoCollector = nil
    }
    
    func isConnected() -> Bool {
        guard let wearablePeripheral = self.wearablePeripheral else {
            return false
        }
        return wearablePeripheral.state == CBPeripheralState.connected && self._deviceInfo != nil
    }
    
    func validateConnection(completion: @escaping (Bool, NSError?) -> Void) {
        completion(isConnected(), nil)
    }
    
    func deviceInfo() -> DeviceInfo? {
        return self._deviceInfo
    }
    
    func nfcState() -> SecurityNFCState {
        return self._nfcState ?? SecurityNFCState.disabled
    }
    
    func executeAPDUCommand(_ apduCommand: APDUCommand) {
        guard let commandData = apduCommand.command?.hexToData() else {
            if let completion = self.paymentDevice.apduResponseHandler {
                completion(nil, NSError.error(code: PaymentDevice.ErrorCode.apduDataNotFull, domain: IPaymentDeviceConnector.self))
            }
            return
        }
        
        sendAPDUData(commandData as Data, sequenceNumber: UInt16(apduCommand.sequence))
    }
    
    func sendAPDUData(_ data: Data, sequenceNumber: UInt16) {
        guard let wearablePeripheral = self.wearablePeripheral, let apduControlCharacteristic = self.apduControlCharacteristic else {
            if let completion = self.paymentDevice.apduResponseHandler {
                self.paymentDevice.apduResponseHandler = nil
                completion(nil, NSError.error(code: PaymentDevice.ErrorCode.deviceDataNotCollected, domain: BluetoothPaymentDeviceConnector.self))
            }
            return
        }
        
        guard !self.sendingAPDU else {
            if let completion = self.paymentDevice.apduResponseHandler {
                self.paymentDevice.apduResponseHandler = nil
                completion(nil, NSError.error(code: PaymentDevice.ErrorCode.waitingForAPDUResponse, domain: BluetoothPaymentDeviceConnector.self))
            }
            return
        }
        
        
        self.sequenceId = sequenceNumber
        
        let apduPacket = NSMutableData()
        var sq16 = UInt16(littleEndian: sequenceId)
        apduPacket.append(Data(bytes: UnsafePointer<UInt8>([0x00] as [UInt8]), count: 1)) // reserved for future use
        apduPacket.append(&sq16, length: MemoryLayout.size(ofValue: sequenceId))
        apduPacket.append(data)
        
        self.sendingAPDU = true
        
        if apduPacket.length <= maxPacketSize {
            wearablePeripheral.writeValue(apduPacket as Data, for: apduControlCharacteristic, type: CBCharacteristicWriteType.withResponse)
        } else {
            sendAPDUContinuation(apduPacket as Data)
        }
        
        startAPDUTimeoutTimer(self.apduSecsTimeout)
    }
    
    func startAPDUTimeoutTimer(_ secs: Double) {
        timeoutTimer?.invalidate()
        timeoutTimer = Timer.scheduledTimer(timeInterval: secs, target:self, selector: #selector(timeoutCheck), userInfo: nil, repeats: false)
    }
    
    func stopAPDUTimeout() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
    
    func timeoutCheck() {
        if (self.sendingAPDU) {
            self.sendingAPDU = false
            
            self.continuation.uuid = CBUUID()
            self.continuation.dataParts.removeAll()
            
            if let completion = self.paymentDevice.apduResponseHandler {
                self.paymentDevice.apduResponseHandler = nil
                completion(nil, NSError.error(code: PaymentDevice.ErrorCode.apduSendingTimeout, domain: BluetoothPaymentDeviceConnector.self))
            }
        }
    }
    
    func sendDeviceControl(_ state: DeviceControlState) -> NSError? {
        guard let deviceControlCharacteristic = self.deviceControlCharacteristic else {
            return NSError.error(code: PaymentDevice.ErrorCode.deviceDataNotCollected, domain: BluetoothPaymentDeviceConnector.self)
        }
        
        let msg = DeviceControlMessage.init(operation: state).msg
        wearablePeripheral?.writeValue(msg as Data, for: deviceControlCharacteristic, type: CBCharacteristicWriteType.withResponse)
        
        return nil
    }
    
    func sendNotification(_ notificationData: Data) -> NSError? {
        guard let notificationCharacteristic = self.notificationCharacteristic else {
            return NSError.error(code: PaymentDevice.ErrorCode.deviceDataNotCollected, domain: BluetoothPaymentDeviceConnector.self)
        }
        
        wearablePeripheral?.writeValue(notificationData, for: notificationCharacteristic, type: CBCharacteristicWriteType.withResponse)
        
        return nil
    }
    
    func writeSecurityState(_ state: SecurityNFCState) -> NSError? {
        guard let wearablePeripheral = self.wearablePeripheral, let securityWriteCharacteristic = self.securityWriteCharacteristic else {
            return NSError.error(code: PaymentDevice.ErrorCode.deviceDataNotCollected, domain: BluetoothPaymentDeviceConnector.self)
        }
        
        wearablePeripheral.writeValue(Data(bytes: UnsafePointer<UInt8>([UInt8(state.rawValue)] as [UInt8]), count: 1), for: securityWriteCharacteristic, type: CBCharacteristicWriteType.withResponse)
        
        return nil
    }
    
    fileprivate func sendAPDUContinuation(_ data: Data) {
        guard let continuationCharacteristicPacket = self.continuationCharacteristicPacket else {
            if let completion = self.paymentDevice.apduResponseHandler {
                self.paymentDevice.apduResponseHandler = nil
                completion(nil, NSError.error(code: PaymentDevice.ErrorCode.deviceDataNotCollected, domain: BluetoothPaymentDeviceConnector.self))
            }
            return
        }
        
        var packetNumber : UInt16 = 0
        let maxDataSize = maxPacketSize - MemoryLayout.size(ofValue: packetNumber)
        
        var bytesSent: Int = 0
        
        sendSignalAboutContiniationStart()
        
        while (bytesSent < data.count) {
            var amountToSend:Int = data.count - bytesSent
            if amountToSend > maxDataSize  {
                amountToSend = maxDataSize
            }
            
            let chunk = Data(bytes:(data as NSData).bytes + bytesSent, count: amountToSend)
            
            let continuationPacket = NSMutableData()
            var pn16 = UInt16(littleEndian: packetNumber)
            continuationPacket.append(&pn16, length: MemoryLayout.size(ofValue: packetNumber))
            continuationPacket.append(chunk)
            
            wearablePeripheral?.writeValue(continuationPacket as Data, for: continuationCharacteristicPacket, type: CBCharacteristicWriteType.withResponse)
            
            bytesSent = bytesSent + amountToSend
            packetNumber += 1
        }
        
        sendSignalAboutContiniationEnd(checkSumValue: data.CRC32HashValue)
    }
    
    fileprivate func sendSignalAboutContiniationStart() {
        guard let continuationCharacteristicControl = self.continuationCharacteristicControl else {
            if let completion = self.paymentDevice.apduResponseHandler {
                self.paymentDevice.apduResponseHandler = nil
                completion(nil, NSError.error(code: PaymentDevice.ErrorCode.deviceDataNotCollected, domain: BluetoothPaymentDeviceConnector.self))
            }
            return
        }
        
        let msg = NSMutableData()
        msg.append(Data(bytes: UnsafePointer<UInt8>([0x00] as [UInt8]), count: 1)) // 0x00 - is start flag
        // UUID is little endian
        msg.append(PAYMENT_CHARACTERISTIC_UUID_APDU_CONTROL.data.reverseEndian)
        
        self.wearablePeripheral?.writeValue(msg as Data, for: continuationCharacteristicControl, type: CBCharacteristicWriteType.withResponse)
    }
    
    fileprivate func sendSignalAboutContiniationEnd(checkSumValue: Int) {
        guard let continuationCharacteristicControl = self.continuationCharacteristicControl else {
            if let completion = self.paymentDevice.apduResponseHandler {
                self.paymentDevice.apduResponseHandler = nil
                completion(nil, NSError.error(code: PaymentDevice.ErrorCode.deviceDataNotCollected, domain: BluetoothPaymentDeviceConnector.self))
            }
            return
        }
        
        var crc32 = UInt32(littleEndian: UInt32(checkSumValue))
        let msg = NSMutableData()
        msg.append(Data(bytes: UnsafePointer<UInt8>([0x01] as [UInt8]), count: 1)) // 0x01 - is end flag
        msg.append(&crc32, length: MemoryLayout.size(ofValue: crc32))
        
        wearablePeripheral?.writeValue(msg as Data, for: continuationCharacteristicControl, type: CBCharacteristicWriteType.withResponse)
    }
    
    fileprivate func processAPDUResponse(_ packet:ApduResultMessage) {
        stopAPDUTimeout()
        
        self.sendingAPDU = false
        
        if self.sequenceId != packet.sequenceId {
            if let apduResponseHandler = self.paymentDevice.apduResponseHandler {
                self.paymentDevice.apduResponseHandler = nil
                apduResponseHandler(nil, NSError.error(code: PaymentDevice.ErrorCode.apduWrongSequenceId, domain: BluetoothPaymentDeviceConnector.self))
            }
            return
        }
        
        self.sequenceId += 1
        
        if let apduResponseHandler = self.paymentDevice.apduResponseHandler {
            self.paymentDevice.apduResponseHandler = nil
            apduResponseHandler(packet, nil)
        }
    }
}

extension BluetoothPaymentDeviceConnector : CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state.rawValue == CBCentralManagerState.poweredOn.rawValue {
            self.paymentDevice?.connectionState = ConnectionState.initialized
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            central.delegate = nil
            self.centralManager = nil
            
            if lastState == CBCentralManagerState.poweredOn {
                resetToDefaultState()
                self.paymentDevice.callCompletionForEvent(PaymentDeviceEventTypes.onDeviceDisconnected)
                self.paymentDevice?.connectionState = ConnectionState.disconnected
            } else {
                self.paymentDevice.callCompletionForEvent(PaymentDeviceEventTypes.onDeviceConnected, params: ["error":NSError.error(code: PaymentDevice.ErrorCode.badBLEState, domain: BluetoothPaymentDeviceConnector.self, message: String(format: PaymentDevice.ErrorCode.badBLEState.description,  central.state.rawValue))])
                self.paymentDevice?.connectionState = ConnectionState.connected
            }
        }
        
        self.lastState = CBCentralManagerState(rawValue: central.state.rawValue)!
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let nameOfDeviceFound = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            if (nameOfDeviceFound.lowercased() == PAYMENTDEVICE_DEVICE_NAME.lowercased()) {
                self.centralManager?.stopScan()
                self.wearablePeripheral = peripheral
                self.wearablePeripheral?.delegate = self
                
                self.centralManager?.connect(peripheral, options: nil)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
        
        self.deviceInfoCollector = BLEDeviceInfoCollector()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        resetToDefaultState()
        
        self.paymentDevice.callCompletionForEvent(PaymentDeviceEventTypes.onDeviceDisconnected)
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.paymentDevice.callCompletionForEvent(PaymentDeviceEventTypes.onDeviceConnected, params: ["error":error as AnyObject? ?? "" as AnyObject])
    }
}

extension BluetoothPaymentDeviceConnector : CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            if service.uuid == PAYMENT_SERVICE_UUID_PAYMENT {
                peripheral.discoverCharacteristics(nil, for: service)
            } else if service.uuid == PAYMENT_SERVICE_UUID_DEVICE_INFO {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            if service.uuid == PAYMENT_SERVICE_UUID_DEVICE_INFO {
                peripheral.readValue(for: characteristic)
            }
            
            if characteristic.uuid == PAYMENT_CHARACTERISTIC_UUID_CONTINUATION_CONTROL {
                self.continuationCharacteristicControl = characteristic
                wearablePeripheral?.setNotifyValue(true, for: characteristic)
            } else if characteristic.uuid == PAYMENT_CHARACTERISTIC_UUID_CONTINUATION_PACKET {
                self.continuationCharacteristicPacket = characteristic
                wearablePeripheral?.setNotifyValue(true, for: characteristic)
            } else if characteristic.uuid == PAYMENT_CHARACTERISTIC_UUID_APDU_CONTROL {
                self.apduControlCharacteristic = characteristic
            } else if characteristic.uuid == PAYMENT_CHARACTERISTIC_UUID_APDU_RESULT {
                wearablePeripheral?.setNotifyValue(true, for: characteristic)
            } else if characteristic.uuid == PAYMENT_CHARACTERISTIC_UUID_NOTIFICATION {
                wearablePeripheral?.setNotifyValue(true, for: characteristic)
            } else if characteristic.uuid == PAYMENT_CHARACTERISTIC_UUID_SECURITY_READ {
                wearablePeripheral?.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            } else if characteristic.uuid == PAYMENT_CHARACTERISTIC_UUID_SECURITY_WRITE {
                self.securityWriteCharacteristic = characteristic
            } else if characteristic.uuid == PAYMENT_CHARACTERISTIC_UUID_SECURE_ELEMENT_ID {
                peripheral.readValue(for: characteristic)
            } else if characteristic.uuid == PAYMENT_CHARACTERISTIC_UUID_DEVICE_CONTROL {
                self.deviceControlCharacteristic = characteristic
            } else if characteristic.uuid == PAYMENT_CHARACTERISTIC_UUID_APPLICATION_CONTROL {
                self.applicationControlCharacteristic = characteristic
                wearablePeripheral?.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if _deviceInfo == nil {
            if let deviceInfoCollector = self.deviceInfoCollector {
                deviceInfoCollector.collectDataFromCharacteristicIfPossible(characteristic)
                if deviceInfoCollector.isCollected {
                    _deviceInfo = deviceInfoCollector.deviceInfo
                    self.paymentDevice.callCompletionForEvent(PaymentDeviceEventTypes.onDeviceConnected, params: ["deviceInfo":_deviceInfo!])
                    self.deviceInfoCollector = nil
                }
            }
        }
        
        if characteristic.uuid == PAYMENT_CHARACTERISTIC_UUID_APDU_RESULT {
            let apduResultMessage = ApduResultMessage(msg: characteristic.value!)
            processAPDUResponse(apduResultMessage)
        } else if characteristic.uuid == PAYMENT_CHARACTERISTIC_UUID_CONTINUATION_CONTROL {
            let continuationControlMessage = ContinuationControlMessage(msg: characteristic.value!)
            if (continuationControlMessage.isBeginning) {
                if (continuation.uuid.uuidString != CBUUID().uuidString) {
                    debugPrint("Previous continuation item exists")
                }
                continuation.uuid = continuationControlMessage.uuid
                continuation.dataParts.removeAll()
                
            } else {
                guard let completeResponse = continuation.data else {
                    if let completion = self.paymentDevice.apduResponseHandler {
                        self.paymentDevice.apduResponseHandler = nil
                        completion(nil, NSError.error(code: PaymentDevice.ErrorCode.apduPacketCorrupted, domain: BluetoothPaymentDeviceConnector.self))
                    }
                    return
                }
                
                let crc = completeResponse.CRC32HashValue
                let crc32 = UInt32(littleEndian: UInt32(crc))
                
                if (crc32 != continuationControlMessage.crc32) {
                    if let completion = self.paymentDevice.apduResponseHandler {
                        self.paymentDevice.apduResponseHandler = nil
                        completion(nil, NSError.error(code: PaymentDevice.ErrorCode.apduPacketCorrupted, domain: BluetoothPaymentDeviceConnector.self))
                    }
                    continuation.uuid = CBUUID()
                    continuation.dataParts.removeAll()
                    return
                }
                
                if continuation.uuid.uuidString == PAYMENT_CHARACTERISTIC_UUID_APDU_RESULT.uuidString {
                    let apduResultMessage = ApduResultMessage(msg: completeResponse)
                    processAPDUResponse(apduResultMessage)
                } else {
                    if let completion = self.paymentDevice.apduResponseHandler {
                        self.paymentDevice.apduResponseHandler = nil
                        completion(nil, NSError.error(code: PaymentDevice.ErrorCode.unknownError, domain: BluetoothPaymentDeviceConnector.self))
                    }
                }
                
                // clear the continuation contents
                continuation.uuid = CBUUID()
                continuation.dataParts.removeAll()
            }
            
        } else if characteristic.uuid == PAYMENT_CHARACTERISTIC_UUID_CONTINUATION_PACKET {
            let msg : ContinuationPacketMessage = ContinuationPacketMessage(msg: characteristic.value!)
            let pos = Int(msg.sortOrder);
            continuation.dataParts[pos] = msg.data
        } else if characteristic.uuid == PAYMENT_CHARACTERISTIC_UUID_NOTIFICATION {
            self.paymentDevice.callCompletionForEvent(PaymentDeviceEventTypes.onNotificationReceived, params: ["notificationData":characteristic.value as AnyObject? ?? Data() as AnyObject])
        } else if characteristic.uuid == PAYMENT_CHARACTERISTIC_UUID_SECURITY_READ {
            if let value = characteristic.value {
                let msg = SecurityStateMessage(msg: value)
                if let securityState = SecurityNFCState(rawValue: Int(msg.nfcState)) {
                    _nfcState = securityState
                    
                    self.paymentDevice.callCompletionForEvent(PaymentDeviceEventTypes.onSecurityStateChanged, params: ["securityState":securityState.rawValue as AnyObject])
                }
            }
        } else if characteristic.uuid == PAYMENT_CHARACTERISTIC_UUID_APPLICATION_CONTROL {
            if let value = characteristic.value {
//                let message = ApplicationControlMessage(msg: value)

                self.paymentDevice.callCompletionForEvent(PaymentDeviceEventTypes.onSecurityStateChanged, params: ["applicationControl":value as AnyObject])
            }
        }
    }
}
