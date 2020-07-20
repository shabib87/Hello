//
//  File.swift
//  
//
//  Created by Shabib Hossain on 2020-07-19.
//

import Foundation

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
