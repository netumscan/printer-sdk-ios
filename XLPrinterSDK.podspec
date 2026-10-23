Pod::Spec.new do |s|
  s.name = 'XLPrinterSDK'
  s.version = '0.3.0-preview.15'
  s.summary = 'NETUM printer SDK for iOS.'
  s.homepage = 'https://github.com/netumscan/printer-sdk-ios'
  s.license = { :type => 'Commercial', :file => 'LICENSE' }
  s.author = { 'NETUM' => 'https://github.com/netumscan' }
  s.source = { :git => 'https://github.com/netumscan/printer-sdk-ios.git', :tag => "v#{s.version}" }
  s.ios.deployment_target = '15.0'
  s.swift_versions = ['5.9']
  s.module_name = 'XLPrinterSDK'
  s.source_files = 'Sources/PrinterSDK/**/*.swift'
  s.vendored_frameworks = 'Binaries/CPrinterSDK.xcframework'
  s.frameworks = 'CoreBluetooth', 'Foundation'
  s.resource_bundles = {
    'XLPrinterSDK_Privacy' => ['Sources/PrinterSDK/Resources/PrivacyInfo.xcprivacy']
  }
  # Local consumers preinstall the matching, SHA-256 checked native archive.
  # Published source packages do not contain Binaries and always verify downloads.
  s.prepare_command = <<-CMD
    set -eu
    if [ -d Binaries/CPrinterSDK.xcframework ]; then
      exit 0
    fi
    archive="$(mktemp -t xlprintersdk.XXXXXX)"
    trap 'rm -f "$archive"' EXIT
    curl --proto '=https' --tlsv1.2 --fail --location --silent --show-error --max-time 120 --retry 2 \
      'https://github.com/netumscan/printer-sdk-ios/releases/download/v0.3.0-preview.15/XLPrinterSDK.xcframework.zip' --output "$archive"
    printf '%s  %s\\n' 'db3ecea6d2a69258781295c8594689af948bfd9935ea28dc4dc2466e714b6d70' "$archive" | shasum -a 256 --check
    mkdir -p Binaries
    unzip -oq "$archive" -d Binaries
  CMD
end
