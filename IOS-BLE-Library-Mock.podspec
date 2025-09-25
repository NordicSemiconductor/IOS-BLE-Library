Pod::Spec.new do |s|
    s.name             = 'IOS-BLE-Library-Mock'
    s.swift_version    = '5.0'
    s.version          = ENV['LIB_VERSION']  
    s.summary          = 'Extension for standard CoreBluetooth framework that is based on Combine and brings Reactive Approach. This version of the library uses CoreBluetoothMock for testing and running on simulator. But it can be usen on real devices and in production as well.'
    s.homepage         = 'https://github.com/NordicSemiconductor/IOS-BLE-Library'
    s.license          = { :type => 'BSD-3-Clause', :file => 'LICENSE' }
    s.author           = { 'Nordic Semiconductor ASA' => 'mag@nordicsemi.no' }
    s.source           = { :git => 'https://github.com/NordicSemiconductor/IOS-BLE-Library.git', :tag => s.version.to_s }
    s.platforms        = { :ios => '13.0', :osx => '12' }
    s.source_files = 'Sources/iOS-BLE-Library-Mock/**/*'

    s.dependency 'CoreBluetoothMock', '~> 1.0.1'
end
