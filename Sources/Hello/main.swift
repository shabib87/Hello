import Darwin
import Foundation
import Combine

let fileManager = FileManager.default

// MARK: xcode spm
// Get .xcworkspace name from console input/yml config file
// Get Package.resolved from .xcworkspace
// read package for github url
// fetch license from github
//$PROJECT_FILE_PATH/project.xcworkspace/xcshareddata/swiftpm/
func abc() {
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
                    let obj = try JSONDecoder().decode(Obbb.self, from: jsonData)
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
                            
                            cancellable = URLSession.shared.dataTaskPublisher(for: url)
                                .sink(receiveCompletion: {
                                    switch $0 {
                                    case .finished:
                                        exit(EXIT_SUCCESS)
                                    case let .failure(error):
                                        print(error)
                                        exit(EXIT_FAILURE)
                                    }
                                }, receiveValue: {
                                    let responseText = String(data: $0.data, encoding: .utf8)!
                                    print(responseText)
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
        //    exit(EXIT_FAILURE)
    }
}

abc()

var cancellable: AnyCancellable?

//func def() {
//    let json = """
//{
//  "object": {
//    "pins": [
//      {
//        "package": "ViewInspector",
//        "repositoryURL": "https://github.com/nalexn/ViewInspector",
//        "state": {
//          "branch": null,
//          "revision": "7a672b0a4c730d829ace40918bd65c21c2f356d9",
//          "version": "0.4.0"
//        }
//      }
//    ]
//  },
//  "version": 1
//}
//"""
//    
//    guard let jsonData = json.data(using: .utf8) else {
//        print("could not make json data from string")
//        return
//    }
//
//    do {
//        let obj = try JSONDecoder().decode(Obbb.self, from: jsonData)
//        print("got value man")
//        obj.object.pins.forEach { pin in
//            print(pin.repositoryURL)
//            let repo = pin.repositoryURL.components(separatedBy: "/")
//            
//            if repo.count > 3 {
//                let owner = repo[3]
//                let repo = pin.package
//                
//                let urlStr = "https://api.github.com/repos/\(owner)/\(repo)/license"
//                print(urlStr)
//                
//                guard let url = URL(string: urlStr) else {
//                    return
//                }
//                
//                cancellable = URLSession.shared.dataTaskPublisher(for: url)
//                    .sink(receiveCompletion: {
//                        switch $0 {
//                        case .finished:
//                            exit(EXIT_SUCCESS)
//                        case let .failure(error):
//                            print(error)
//                            exit(EXIT_FAILURE)
//                        }
//                    }, receiveValue: {
//                        let responseText = String(data: $0.data, encoding: .utf8)!
//                        print(responseText)
//                    })
//
//                RunLoop.current.run()
//            }
//        }
//    } catch let error as NSError {
//        print("Failed to load: \(error)")
//    }
//}

//def()

//let url1 = URL(string: "https://api.github.com/repos/nalexn/ViewInspector/license")!

struct Obbb: Decodable {
    let object: PackageItems
}

struct PackageItems: Codable {
    let pins: [PackageObj]
}

struct PackageObj: Codable {
    let package: String
    let repositoryURL: String
    let state: PackageObjState
}

struct PackageObjState: Codable {
    let version: String
}


// MARK: SPM
//do {
//    let root = try fileManager.contentsOfDirectory(atPath: ".")
//    var isDir : ObjCBool = false
//    if root.contains(".build"),
//        fileManager.fileExists(atPath: ".build", isDirectory:&isDir)
//        {
//            if isDir.boolValue {
//                let spm = try fileManager.contentsOfDirectory(atPath: ".build/")
//                if spm.contains("checkouts"),
//                    fileManager.fileExists(atPath: ".build/checkouts", isDirectory:&isDir), isDir.boolValue {
//                    let checkouts = try fileManager.contentsOfDirectory(atPath: ".build/checkouts")
//                    try checkouts.forEach { package in
//                        print(">>> \(package)")
//                        let files = try fileManager.contentsOfDirectory(atPath: ".build/checkouts/\(package)")
//                        try files.forEach { file in
//                            if file.contains("LICENSE"),
//                                fileManager.fileExists(atPath: ".build/checkouts", isDirectory:&isDir), isDir.boolValue {
//                                let url = URL(fileURLWithPath: ".build/checkouts/\(package)/\(file)")
//                                let license = try String(contentsOf: url, encoding: .utf8)
//                                print(license)
//                            }
//                        }
//                        print(">>>")
//                    }
//                }
//            }
//    }
//} catch {
//    print("coundn't read files: \(error.localizedDescription)")
//    exit(EXIT_FAILURE)
//}

// MARK: POD

//do {
//    let root = try fileManager.contentsOfDirectory(atPath: ".")
//    var isDir : ObjCBool = false
//
//    if root.contains("Pods"),
//        fileManager.fileExists(atPath: "Pods", isDirectory:&isDir) {
//        if isDir.boolValue {
//            // file exists and is a directory
//            let pods = try fileManager.contentsOfDirectory(atPath: "Pods/")
//            try pods.forEach { pod in
//                if fileManager.fileExists(atPath: "Pods/\(pod)", isDirectory: &isDir) {
//                    if isDir.boolValue {
//                        // file exists and is a directory
//                        print("<<<")
//                        print(pod)
//                        let files = try fileManager.contentsOfDirectory(atPath: "Pods/\(pod)")
//                        try files.forEach { file in
//                            if fileManager.fileExists(atPath: "Pods/\(pod)/\(file)", isDirectory:&isDir) {
//                                if !isDir.boolValue,
//                                 file.contains("LICENSE") {
//                                    let url = URL(fileURLWithPath: "Pods/\(pod)/\(file)")
//                                    let license = try String(contentsOf: url, encoding: .utf8)
//                                    print(license)
//                                }
//                            }
//                        }
//                        print(">>>")
//                    }
//                }
//            }
//        } else {
//            // file exists and is not a directory
//        }
//    } else {
//        // file does not exist
//    }
//} catch {
//    print("coundn't read files: \(error.localizedDescription)")
//    exit(EXIT_FAILURE)
//}
