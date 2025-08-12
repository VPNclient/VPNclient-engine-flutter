import Foundation
import LibXray

/// Swift wrapper for LibXray functions
public class LibXrayWrapper {
    
    private static let instance = LibXrayWrapper()
    
    public static func shared() -> LibXrayWrapper {
        return instance
    }
    
    private init() {
        setupDatFiles()
    }
    
    private func setupDatFiles() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let datDir = documentsPath + "/libxray_dat"
        
        // Create dat directory if it doesn't exist
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: datDir) {
            try? fileManager.createDirectory(atPath: datDir, withIntermediateDirectories: true)
        }
        
        // Copy dat files from bundle if they don't exist in documents
        let datFiles = ["geoip.dat", "geosite.dat"]
        for datFile in datFiles {
            let documentsFile = datDir + "/" + datFile
            if !fileManager.fileExists(atPath: documentsFile) {
                if let bundlePath = Bundle.main.path(forResource: datFile.replacingOccurrences(of: ".dat", with: ""), ofType: "dat", inDirectory: "dat") {
                    try? fileManager.copyItem(atPath: bundlePath, toPath: documentsFile)
                }
            }
        }
    }
    
    /// Test Xray configuration
    /// - Parameters:
    ///   - datDir: Directory containing geo data files
    ///   - configPath: Path to Xray configuration file
    /// - Returns: Success status
    public func testXray(datDir: String, configPath: String) -> Bool {
        let request = TestXrayRequest(datDir: datDir, configPath: configPath)
        let jsonData = try? JSONEncoder().encode(request)
        let base64String = jsonData?.base64EncodedString() ?? ""
        
        let response = LibXray.testXray(base64String)
        let decodedResponse = decodeResponse(response)
        
        return decodedResponse.success
    }
    
    /// Run Xray with configuration file
    /// - Parameters:
    ///   - datDir: Directory containing geo data files
    ///   - configPath: Path to Xray configuration file
    /// - Returns: Success status
    public func runXray(datDir: String, configPath: String) -> Bool {
        let request = RunXrayRequest(datDir: datDir, configPath: configPath)
        let jsonData = try? JSONEncoder().encode(request)
        let base64String = jsonData?.base64EncodedString() ?? ""
        
        let response = LibXray.runXray(base64String)
        let decodedResponse = decodeResponse(response)
        
        return decodedResponse.success
    }
    
    /// Run Xray with JSON configuration
    /// - Parameters:
    ///   - datDir: Directory containing geo data files
    ///   - configJSON: Xray configuration as JSON string
    /// - Returns: Success status
    public func runXrayFromJSON(datDir: String, configJSON: String) -> Bool {
        let request = RunXrayFromJSONRequest(datDir: datDir, configJSON: configJSON)
        let jsonData = try? JSONEncoder().encode(request)
        let base64String = jsonData?.base64EncodedString() ?? ""
        
        let response = LibXray.runXrayFromJSON(base64String)
        let decodedResponse = decodeResponse(response)
        
        return decodedResponse.success
    }
    
    /// Stop Xray
    /// - Returns: Success status
    public func stopXray() -> Bool {
        let response = LibXray.stopXray()
        let decodedResponse = decodeResponse(response)
        
        return decodedResponse.success
    }
    
    /// Get Xray state
    /// - Returns: True if Xray is running
    public func getXrayState() -> Bool {
        return LibXray.getXrayState()
    }
    
    /// Get Xray version
    /// - Returns: Version string
    public func getXrayVersion() -> String {
        return LibXray.xrayVersion()
    }
    
    /// Ping server with configuration
    /// - Parameters:
    ///   - datDir: Directory containing geo data files
    ///   - configPath: Path to Xray configuration file
    ///   - timeout: Ping timeout in seconds
    ///   - url: URL to ping
    ///   - proxy: Proxy configuration
    /// - Returns: Ping delay in milliseconds, -1 if failed
    public func ping(datDir: String, configPath: String, timeout: Int, url: String, proxy: String) -> Int64 {
        let request = PingRequest(datDir: datDir, configPath: configPath, timeout: timeout, url: url, proxy: proxy)
        let jsonData = try? JSONEncoder().encode(request)
        let base64String = jsonData?.base64EncodedString() ?? ""
        
        let response = LibXray.ping(base64String)
        let decodedResponse = decodeResponse(response)
        
        return decodedResponse.data ?? -1
    }
    
    // MARK: - Helper Methods
    
    private func decodeResponse<T: Codable>(_ base64String: String) -> LibXrayResponse<T> {
        guard let data = Data(base64Encoded: base64String),
              let response = try? JSONDecoder().decode(LibXrayResponse<T>.self, from: data) else {
            return LibXrayResponse<T>(success: false, data: nil, error: "Failed to decode response")
        }
        return response
    }
}

// MARK: - Request Models

struct TestXrayRequest: Codable {
    let datDir: String
    let configPath: String
}

struct RunXrayRequest: Codable {
    let datDir: String
    let configPath: String
}

struct RunXrayFromJSONRequest: Codable {
    let datDir: String
    let configJSON: String
}

struct PingRequest: Codable {
    let datDir: String
    let configPath: String
    let timeout: Int
    let url: String
    let proxy: String
}

// MARK: - Response Models

struct LibXrayResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
} 