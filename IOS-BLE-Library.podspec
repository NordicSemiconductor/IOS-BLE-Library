Pod::Spec.new do |s|
    s.name             = 'IOS-BLE-Library'
    s.version          = '0.1.1'
    s.summary          = 'Extension for standard CoreBluetooth framework that is based on Combine and brings Reactive Approach.'
    s.homepage         = 'https://github.com/NordicSemiconductor/IOS-BLE-Library'
    s.license          = { :type => 'BSD-3-Clause', :file => 'LICENSE' }
    s.author           = { 'Nordic Semiconductor ASA' => 'mag@nordicsemi.no' }
    s.source           = { :git => 'https://github.com/NordicSemiconductor/IOS-BLE-Library.git', :tag => '0.1.1' }
    # s.source           = { :git => 'https://github.com/NordicSemiconductor/IOS-BLE-Library.git', :branch => 'feature/pod_integration' }
    s.platforms        = :ios 
    s.ios.deployment_target = '13.0'
    # s.osx.deployment_target = '12.0'
    s.source_files = 'Sources/iOS-BLE-Library/**/*'

    s.dependency 'CoreBluetoothMock', '~> 0.16.0'

  end