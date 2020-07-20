import Darwin
import Foundation
import Combine

let fileManager = FileManager.default

enum SessionError: Error {
    case statusCode(HTTPURLResponse)
}

// MARK: xcode spm
func getLicenseFromXcodeManagedSPM() {
    do {
        var path = "\(fileManager.currentDirectoryPath)"
        if let projName = path.components(separatedBy: "/").last {
            path.append("/\(projName).xcodeproj/project.xcworkspace/xcshareddata/swiftpm/")
            let swiftpm = try fileManager.contentsOfDirectory(atPath: path)
            var isDir : ObjCBool = false
            if swiftpm.contains("Package.resolved"),
                fileManager.fileExists(atPath: "Package.resolved", isDirectory:&isDir),
                !isDir.boolValue {
                path.append("/Package.resolved")
                let url = URL(fileURLWithPath: path)
                let package = try String(contentsOf: url, encoding: .utf8)
                
                print(package)
                guard let jsonData = package.data(using: .utf8) else {
                    print("could not make json data from string")
                    return
                }

                do {
                    let obj = try JSONDecoder().decode(WrappedPackageItems.self, from: jsonData)
                    print("got value man")
                    
                    obj.object.pins.forEach { pin in
                        print(pin.repositoryURL)
                        let repo = pin.repositoryURL.components(separatedBy: "/")
                        
                        if repo.count > 3 {
                            let owner = repo[3]
                            let repo = pin.package
                            
                            let urlStr = "https://api.github.com/repos/\(owner)/\(repo)/license"
                            print(urlStr)
                            
                            guard let url = URL(string: urlStr) else {
                                return
                            }
                            
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            
                            cancellable = URLSession.shared.dataTaskPublisher(for: url)
                                .tryMap { data, response -> Data in
                                    if let response = response as? HTTPURLResponse,
                                        (200..<300).contains(response.statusCode) == false {
                                        throw SessionError.statusCode(response)
                                    }

                                    return data
                                }
                            .decode(type: LicenseInfo.self, decoder: decoder)
                                .sink(receiveCompletion: {
                                    switch $0 {
                                    case .finished:
                                        print("task complete")
                                    case let .failure(error):
                                        print(error)
                                        exit(EXIT_FAILURE)
                                    }
                                }, receiveValue: {
                                    print("Recieved download url")
                                    print($0.downloadUrl)
                                    
                                    guard let url = URL(string: $0.downloadUrl) else {
                                        print("invalid download url")
                                        return
                                    }
                                    Downloader.shared.download(from: url)
                                })

                            RunLoop.current.run()
                        }
                    }
                    
                } catch let error as NSError {
                    print("Failed to load: \(error)")
                }
            }
        }
    } catch {
        print("coundn't read files: \(error)")
    }
}

var cancellable: AnyCancellable?

struct WrappedPackageItems: Decodable {
    let object: PackageItems
}

struct PackageItems: Decodable {
    let pins: [PackageObj]
}

struct PackageObj: Decodable {
    let package: String
    let repositoryURL: String
    let state: PackageObjState
}

struct PackageObjState: Decodable {
    let version: String
}

struct LicenseInfo: Decodable {
    let downloadUrl: String
}


// MARK: SPM
func getLicenseFromLocalSPM() {
    do {
        let root = try fileManager.contentsOfDirectory(atPath: ".")
        var isDir : ObjCBool = false
        if root.contains(".build"),
            fileManager.fileExists(atPath: ".build", isDirectory:&isDir)
            {
                if isDir.boolValue {
                    let spm = try fileManager.contentsOfDirectory(atPath: ".build/")
                    if spm.contains("checkouts"),
                        fileManager.fileExists(atPath: ".build/checkouts", isDirectory:&isDir), isDir.boolValue {
                        let checkouts = try fileManager.contentsOfDirectory(atPath: ".build/checkouts")
                        try checkouts.forEach { package in
                            print(">>> \(package)")
                            let files = try fileManager.contentsOfDirectory(atPath: ".build/checkouts/\(package)")
                            try files.forEach { file in
                                if file.contains("LICENSE"),
                                    fileManager.fileExists(atPath: ".build/checkouts", isDirectory:&isDir), isDir.boolValue {
                                    let url = URL(fileURLWithPath: ".build/checkouts/\(package)/\(file)")
                                    let license = try String(contentsOf: url, encoding: .utf8)
                                    print(license)
                                }
                            }
                            print(">>>")
                        }
                    }
                }
        }
    } catch {
        print("coundn't read files: \(error.localizedDescription)")
        exit(EXIT_FAILURE)
    }
}

// MARK: POD

func getLicensenseFromCocopod() {
    do {
        let root = try fileManager.contentsOfDirectory(atPath: ".")
        var isDir : ObjCBool = false

        if root.contains("Pods"),
            fileManager.fileExists(atPath: "Pods", isDirectory:&isDir) {
            if isDir.boolValue {
                // file exists and is a directory
                let pods = try fileManager.contentsOfDirectory(atPath: "Pods/")
                try pods.forEach { pod in
                    if fileManager.fileExists(atPath: "Pods/\(pod)", isDirectory: &isDir) {
                        if isDir.boolValue {
                            // file exists and is a directory
                            print("<<<")
                            print(pod)
                            let files = try fileManager.contentsOfDirectory(atPath: "Pods/\(pod)")
                            try files.forEach { file in
                                if fileManager.fileExists(atPath: "Pods/\(pod)/\(file)", isDirectory:&isDir) {
                                    if !isDir.boolValue,
                                     file.contains("LICENSE") {
                                        let url = URL(fileURLWithPath: "Pods/\(pod)/\(file)")
                                        let license = try String(contentsOf: url, encoding: .utf8)
                                        print(license)
                                    }
                                }
                            }
                            print(">>>")
                        }
                    }
                }
            } else {
                // file exists and is not a directory
            }
        } else {
            // file does not exist
        }
    } catch {
        print("coundn't read files: \(error.localizedDescription)")
        exit(EXIT_FAILURE)
    }
}

final class Downloader: NSObject, URLSessionDownloadDelegate {
    static let shared = Downloader()
    
    private override init() {}
    
    func download(from url: URL) {
        let configuration = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let session = URLSession(configuration: configuration,
                                 delegate: self,
                                 delegateQueue: operationQueue)
        
        let downloadTask = session.downloadTask(with: url)
        
        downloadTask.resume()
        RunLoop.current.run()
    }
    
    func urlSession(_ session: URLSession,
                    didBecomeInvalidWithError error: Error?) {
        print(error as Any)
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        print(error as Any)
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        do {
            let license = try String(contentsOf: location, encoding: .utf8)
            print(license)
            exit(EXIT_SUCCESS)
        } catch {
            print("coundn't read files: \(error.localizedDescription)")
            exit(EXIT_FAILURE)
        }
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        
        let percentDownloaded = totalBytesWritten / totalBytesExpectedToWrite
        DispatchQueue.main.async {
            print("downloaded \(percentDownloaded * 100)%")
        }
    }
}

final class TestLicenseDownload: NSObject {
    func testing() {
        let json = """
    {
      "object": {
        "pins": [
          {
            "package": "ViewInspector",
            "repositoryURL": "https://github.com/nalexn/ViewInspector",
            "state": {
              "branch": null,
              "revision": "7a672b0a4c730d829ace40918bd65c21c2f356d9",
              "version": "0.4.0"
            }
          }
        ]
      },
      "version": 1
    }
    """

        guard let jsonData = json.data(using: .utf8) else {
            print("could not make json data from string")
            return
        }

        do {
            let obj = try JSONDecoder().decode(WrappedPackageItems.self, from: jsonData)
            print("got value man")
            obj.object.pins.forEach { pin in
                print(pin.repositoryURL)
                let repo = pin.repositoryURL.components(separatedBy: "/")

                if repo.count > 3 {
                    let owner = repo[3]
                    let repo = pin.package

                    let urlStr = "https://api.github.com/repos/\(owner)/\(repo)/license"
                    print(urlStr)

                    guard let url = URL(string: urlStr) else {
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    cancellable = URLSession.shared.dataTaskPublisher(for: url)
                        .tryMap { data, response -> Data in
                            if let response = response as? HTTPURLResponse,
                                (200..<300).contains(response.statusCode) == false {
                                throw SessionError.statusCode(response)
                            }

                            return data
                        }
                    .decode(type: LicenseInfo.self, decoder: decoder)
                        .sink(receiveCompletion: {
                            switch $0 {
                            case .finished:
                                print("task complete")
                            case let .failure(error):
                                print(error)
                                exit(EXIT_FAILURE)
                            }
                        }, receiveValue: {
                            print("Recieved download url")
                            print($0.downloadUrl)
                            
                            guard let url = URL(string: $0.downloadUrl) else {
                                print("invalid download url")
                                return
                            }
                            
                            Downloader.shared.download(from: url)
                        })

                    RunLoop.current.run()
                }
            }
        } catch let error as NSError {
            print("Failed to load: \(error)")
        }
    }
}

getLicenseFromLocalSPM()
getLicensenseFromCocopod()
getLicenseFromXcodeManagedSPM()
//TestLicenseDownload().testing()
