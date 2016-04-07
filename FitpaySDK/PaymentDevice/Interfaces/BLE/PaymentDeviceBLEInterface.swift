import CoreBluetooth

internal class PaymentDeviceBLEInterface : NSObject, PaymentDeviceBaseInterface {
    var paymentDevice : PaymentDevice
    
    var centralManager : CBCentralManager?
    var wearablePeripheral : CBPeripheral?
    var lastState : CBCentralManagerState = CBCentralManagerState.PoweredOff
    
    var continuationCharacteristicControl: CBCharacteristic?
    var continuationCharacteristicPacket: CBCharacteristic?
    var apduControlCharacteristic: CBCharacteristic?
    var securityWriteCharacteristic: CBCharacteristic?
    var deviceControlCharacteristic: CBCharacteristic?
    var applicationControlCharacteristic: CBCharacteristic?
    
    var continuation : Continuation = Continuation()
    var deviceInfoCollector : BLEDeviceInfoCollector?
    
    private var _deviceInfo : DeviceInfo?
    
    let MaxPacketSize : Int = 20
    var sequenceId: UInt16 = 0
    var sendingAPDU : Bool = false
    
    required init(paymentDevice device: PaymentDevice) {
        self.paymentDevice = device
    }
    
    func connect() {
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        if lastState == CBCentralManagerState.PoweredOn {
            self.centralManager?.scanForPeripheralsWithServices(nil, options: nil)
        }
    }
    
    func disconnect() {
        resetToDefaultState()
            
        if let onDeviceDisconnected = self.paymentDevice.onDeviceDisconnected {
            onDeviceDisconnected()
        }
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
        return wearablePeripheral.state == CBPeripheralState.Connected && self._deviceInfo != nil
    }
    
    func deviceInfo() -> DeviceInfo? {
        return self._deviceInfo
    }
    
    func sendAPDUData(data: NSData, sequenceNumber: UInt16) {
        guard let wearablePeripheral = self.wearablePeripheral, apduControlCharacteristic = self.apduControlCharacteristic else {
            if let completion = self.paymentDevice.apduResponseHandler {
                self.paymentDevice.apduResponseHandler = nil
                completion(apduResponse: nil, error: NSError.error(code: PaymentDevice.ErrorCode.DeviceDataNotCollected, domain: PaymentDeviceBLEInterface.self))
            }
            return
        }
        
        guard !self.sendingAPDU else {
            if let completion = self.paymentDevice.apduResponseHandler {
                self.paymentDevice.apduResponseHandler = nil
                completion(apduResponse: nil, error: NSError.error(code: PaymentDevice.ErrorCode.WaitingForAPDUResponse, domain: PaymentDeviceBLEInterface.self))
            }
            return
        }
        
        self.sequenceId = sequenceNumber
        
        let apduPacket = NSMutableData()
        var sq16 = UInt16(littleEndian: sequenceId)
        apduPacket.appendData(NSData(bytes: [0x00] as [UInt8], length: 1)) // reserved for future use
        apduPacket.appendBytes(&sq16, length: sizeofValue(sequenceId))
        apduPacket.appendData(data)
        
        self.sendingAPDU = true
        
        if apduPacket.length <= MaxPacketSize {
            wearablePeripheral.writeValue(apduPacket, forCharacteristic: apduControlCharacteristic, type: CBCharacteristicWriteType.WithResponse)
        } else {
            sendAPDUContinuation(apduPacket)
        }
    }
    
    func sendDeviceControl(state: PaymentDevice.DeviceControlState) -> ErrorType? {
        guard let deviceControlCharacteristic = self.deviceControlCharacteristic else {
            return NSError.error(code: PaymentDevice.ErrorCode.DeviceDataNotCollected, domain: PaymentDeviceBLEInterface.self)
        }
        
        let msg = DeviceControlMessage.init(operation: state).msg
        wearablePeripheral?.writeValue(msg, forCharacteristic: deviceControlCharacteristic, type: CBCharacteristicWriteType.WithResponse)
        
        return nil
    }
    
    func writeSecurityState(state: PaymentDevice.SecurityState) -> ErrorType? {
        guard let wearablePeripheral = self.wearablePeripheral, securityWriteCharacteristic = self.securityWriteCharacteristic else {
            return NSError.error(code: PaymentDevice.ErrorCode.DeviceDataNotCollected, domain: PaymentDeviceBLEInterface.self)
        }
        
        wearablePeripheral.writeValue(NSData(bytes: [UInt8(state.rawValue)] as [UInt8], length: 1), forCharacteristic: securityWriteCharacteristic, type: CBCharacteristicWriteType.WithResponse)
        
        return nil
    }
    
    private func sendAPDUContinuation(data: NSData) {
        guard let continuationCharacteristicPacket = self.continuationCharacteristicPacket else {
            if let completion = self.paymentDevice.apduResponseHandler {
                self.paymentDevice.apduResponseHandler = nil
                completion(apduResponse: nil, error: NSError.error(code: PaymentDevice.ErrorCode.DeviceDataNotCollected, domain: PaymentDeviceBLEInterface.self))
            }
            return
        }
        
        var packetNumber : UInt16 = 0
        let maxDataSize = MaxPacketSize - sizeofValue(packetNumber)
        
        var bytesSent: Int = 0
        
        sendSignalAboutContiniationStart()
        
        while (bytesSent < data.length) {
            var amountToSend:Int = data.length - bytesSent
            if amountToSend > maxDataSize  {
                amountToSend = maxDataSize
            }
            
            let chunk = NSData(bytes: data.bytes + bytesSent, length: amountToSend)
            
            let continuationPacket = NSMutableData()
            var pn16 = UInt16(littleEndian: packetNumber)
            continuationPacket.appendBytes(&pn16, length: sizeofValue(packetNumber))
            continuationPacket.appendData(chunk)
            
            wearablePeripheral?.writeValue(continuationPacket, forCharacteristic: continuationCharacteristicPacket, type: CBCharacteristicWriteType.WithResponse)
            
            bytesSent = bytesSent + amountToSend
            packetNumber += 1
        }
        
        sendSignalAboutContiniationEnd(checkSumValue: data.CRC32HashValue)
    }
    
    private func sendSignalAboutContiniationStart() {
        guard let continuationCharacteristicControl = self.continuationCharacteristicControl else {
            if let completion = self.paymentDevice.apduResponseHandler {
                self.paymentDevice.apduResponseHandler = nil
                completion(apduResponse: nil, error: NSError.error(code: PaymentDevice.ErrorCode.DeviceDataNotCollected, domain: PaymentDeviceBLEInterface.self))
            }
            return
        }
        
        let msg = NSMutableData()
        msg.appendData(NSData(bytes: [0x00] as [UInt8], length: 1)) // 0x00 - is start flag
        // UUID is little endian
        msg.appendData(PAYMENT_CHARACTERISTIC_UUID_APDU_CONTROL.data.reverseEndian)
        
        self.wearablePeripheral?.writeValue(msg, forCharacteristic: continuationCharacteristicControl, type: CBCharacteristicWriteType.WithResponse)
    }
    
    private func sendSignalAboutContiniationEnd(checkSumValue checkSumValue: Int) {
        guard let continuationCharacteristicControl = self.continuationCharacteristicControl else {
            if let completion = self.paymentDevice.apduResponseHandler {
                self.paymentDevice.apduResponseHandler = nil
                completion(apduResponse: nil, error: NSError.error(code: PaymentDevice.ErrorCode.DeviceDataNotCollected, domain: PaymentDeviceBLEInterface.self))
            }
            return
        }
        
        var crc32 = UInt32(littleEndian: UInt32(checkSumValue))
        let msg = NSMutableData()
        msg.appendData(NSData(bytes: [0x01] as [UInt8], length: 1)) // 0x01 - is end flag
        msg.appendBytes(&crc32, length: sizeofValue(crc32))
        
        wearablePeripheral?.writeValue(msg, forCharacteristic: continuationCharacteristicControl, type: CBCharacteristicWriteType.WithResponse)
    }
    
    private func processAPDUResponse(packet:ApduResultMessage) {
        if self.sequenceId != packet.sequenceId {
            if let apduResponseHandler = self.paymentDevice.apduResponseHandler {
                self.paymentDevice.apduResponseHandler = nil
                apduResponseHandler(apduResponse: nil, error: NSError.error(code: PaymentDevice.ErrorCode.APDUWrongSequenceId, domain: PaymentDeviceBLEInterface.self))
            }
            return
        }
        
        self.sequenceId += 1
        self.sendingAPDU = false
        
        if let apduResponseHandler = self.paymentDevice.apduResponseHandler {
            self.paymentDevice.apduResponseHandler = nil
            apduResponseHandler(apduResponse: packet, error: nil)
        }
    }
}

extension PaymentDeviceBLEInterface : CBCentralManagerDelegate {
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == CBCentralManagerState.PoweredOn {
            central.scanForPeripheralsWithServices(nil, options: nil)
        } else {
            central.delegate = nil
            self.centralManager = nil
            
            if lastState == CBCentralManagerState.PoweredOn {
                resetToDefaultState()
                if let onDeviceDisconnected = self.paymentDevice.onDeviceDisconnected {
                    onDeviceDisconnected()
                }
            } else if let onDeviceConnected = self.paymentDevice.onDeviceConnected {
                onDeviceConnected(deviceInfo: nil, error: NSError.error(code: PaymentDevice.ErrorCode.BadBLEState, domain: PaymentDeviceBLEInterface.self, message: String(format: PaymentDevice.ErrorCode.BadBLEState.description,  central.state.rawValue)))
            }
        }
        
        self.lastState = central.state
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if let nameOfDeviceFound = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            if (nameOfDeviceFound.lowercaseString == PAYMENTDEVICE_DEVICE_NAME.lowercaseString) {
                self.centralManager?.stopScan()
                self.wearablePeripheral = peripheral
                self.wearablePeripheral?.delegate = self
                
                self.centralManager?.connectPeripheral(peripheral, options: nil)
            }
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
        
        self.deviceInfoCollector = BLEDeviceInfoCollector()
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        resetToDefaultState()
        
        if let onDeviceDisconnected = self.paymentDevice.onDeviceDisconnected {
            onDeviceDisconnected()
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        if let onDeviceConnected = self.paymentDevice.onDeviceConnected {
            onDeviceConnected(deviceInfo: nil, error: error)
        }
    }
}

extension PaymentDeviceBLEInterface : CBPeripheralDelegate {
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            if service.UUID == PAYMENT_SERVICE_UUID_PAYMENT {
                peripheral.discoverCharacteristics(nil, forService: service)
            } else if service.UUID == PAYMENT_SERVICE_UUID_DEVICE_INFO {
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        for characteristic in service.characteristics! {
            if service.UUID == PAYMENT_SERVICE_UUID_DEVICE_INFO {
                peripheral.readValueForCharacteristic(characteristic)
            }
            
            if characteristic.UUID == PAYMENT_CHARACTERISTIC_UUID_CONTINUATION_CONTROL {
                self.continuationCharacteristicControl = characteristic
                wearablePeripheral?.setNotifyValue(true, forCharacteristic: characteristic)
            } else if characteristic.UUID == PAYMENT_CHARACTERISTIC_UUID_CONTINUATION_PACKET {
                self.continuationCharacteristicPacket = characteristic
                wearablePeripheral?.setNotifyValue(true, forCharacteristic: characteristic)
            } else if (characteristic.UUID == PAYMENT_CHARACTERISTIC_UUID_APDU_CONTROL) {
                self.apduControlCharacteristic = characteristic
            } else if (characteristic.UUID == PAYMENT_CHARACTERISTIC_UUID_APDU_RESULT) {
                wearablePeripheral?.setNotifyValue(true, forCharacteristic: characteristic)
            } else if (characteristic.UUID == PAYMENT_CHARACTERISTIC_UUID_TRANSACTION_NOTIFICATION) {
                wearablePeripheral?.setNotifyValue(true, forCharacteristic: characteristic)
            } else if (characteristic.UUID == PAYMENT_CHARACTERISTIC_UUID_SECURITY_READ) {
                wearablePeripheral?.setNotifyValue(true, forCharacteristic: characteristic)
            } else if (characteristic.UUID == PAYMENT_CHARACTERISTIC_UUID_SECURITY_WRITE) {
                self.securityWriteCharacteristic = characteristic
            } else if (characteristic.UUID == PAYMENT_CHARACTERISTIC_UUID_SECURE_ELEMENT_ID) {
                peripheral.readValueForCharacteristic(characteristic)
            } else if (characteristic.UUID == PAYMENT_CHARACTERISTIC_UUID_DEVICE_CONTROL) {
                self.deviceControlCharacteristic = characteristic
            } else if (characteristic.UUID == PAYMENT_CHARACTERISTIC_UUID_APPLICATION_CONTROL) {
                self.applicationControlCharacteristic = characteristic
                wearablePeripheral?.setNotifyValue(true, forCharacteristic: characteristic)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if _deviceInfo == nil {
            if let deviceInfoCollector = self.deviceInfoCollector {
                deviceInfoCollector.collectDataFromCharacteristicIfPossible(characteristic)
                if deviceInfoCollector.isCollected {
                    _deviceInfo = deviceInfoCollector.deviceInfo
                    if let onDeviceConnected = self.paymentDevice.onDeviceConnected {
                        onDeviceConnected(deviceInfo: _deviceInfo, error: nil)
                    }
                    self.deviceInfoCollector = nil
                }
            }
        }
        
        if characteristic.UUID == PAYMENT_CHARACTERISTIC_UUID_APDU_RESULT {
            let apduResultMessage = ApduResultMessage(msg: characteristic.value!)
            processAPDUResponse(apduResultMessage)
        } else if characteristic.UUID == PAYMENT_CHARACTERISTIC_UUID_CONTINUATION_CONTROL {
            let continuationControlMessage = ContinuationControlMessage(msg: characteristic.value!)
            if (continuationControlMessage.isBeginning) {
                if (continuation.uuid.UUIDString != CBUUID().UUIDString) {
                    debugPrint("Previous continuation item exists")
                }
                continuation.uuid = continuationControlMessage.uuid
                continuation.data.removeAll()
                
            } else {
                //TODO: need to verify all packets received - change data structure to dictionary
                let completeResponse = NSMutableData()
                for packet in continuation.data {
                    completeResponse.appendData(packet)
                }
                let crc = completeResponse.CRC32HashValue
                let crc32 = UInt32(littleEndian: UInt32(crc))
                
                if (crc32 != continuationControlMessage.crc32) {
                    if let completion = self.paymentDevice.apduResponseHandler {
                        self.paymentDevice.apduResponseHandler = nil
                        completion(apduResponse: nil, error: NSError.error(code: PaymentDevice.ErrorCode.APDUPacketCorrupted, domain: PaymentDeviceBLEInterface.self))
                    }
                    return
                }
                
                if (continuation.uuid.UUIDString == PAYMENT_CHARACTERISTIC_UUID_APDU_RESULT.UUIDString) {
                    let apduResultMessage = ApduResultMessage(msg: completeResponse)
                    processAPDUResponse(apduResultMessage)
                } else {
                    if let completion = self.paymentDevice.apduResponseHandler {
                        self.paymentDevice.apduResponseHandler = nil
                        completion(apduResponse: nil, error: NSError.error(code: PaymentDevice.ErrorCode.UnknownError, domain: PaymentDeviceBLEInterface.self))
                    }
                }
                
                // clear the continuation contents
                continuation.uuid = CBUUID()
                continuation.data.removeAll()
            }
            
        } else if characteristic.UUID == PAYMENT_CHARACTERISTIC_UUID_CONTINUATION_PACKET {
            let msg : ContinuationPacketMessage = ContinuationPacketMessage(msg: characteristic.value!)
            let pos = Int(msg.sortOrder);
            continuation.data.insert(msg.data, atIndex: pos)
        } else if characteristic.UUID == PAYMENT_CHARACTERISTIC_UUID_TRANSACTION_NOTIFICATION {
            if let onTransactionNotificationReceived = self.paymentDevice.onTransactionNotificationReceived {
                onTransactionNotificationReceived(transactionData: characteristic.value)
            }
        } else if characteristic.UUID == PAYMENT_CHARACTERISTIC_UUID_SECURITY_READ {
            if let value = characteristic.value {
                let msg = SecurityStateMessage(msg: value)
                if let securityState = PaymentDevice.SecurityState(rawValue: Int(msg.nfcState)) {
                    // New security state here, save it?
                    
                    if let onSecurityStateChanged = self.paymentDevice.onSecurityStateChanged {
                        onSecurityStateChanged(securityState: securityState)
                    }
                }
            }
        } else if characteristic.UUID == PAYMENT_CHARACTERISTIC_UUID_APPLICATION_CONTROL {
            if let value = characteristic.value {
                if let onApplicationControlReceived = self.paymentDevice.onApplicationControlReceived {
                    let message = ApplicationControlMessage(msg: value)
                    onApplicationControlReceived(applicationControl: message)
                }
            }
        }
    }
}
