//
//  TestLicenseDownload.swift
//  Created by Shabib Hossain on 2020-07-19.
//

import Foundation

/*
 download should be happening each completion regardless of success of failure
 */

final class TestLicenseDownload: NSObject {
    func testing() {
        let json =
        """
        {
          "object": {
            "pins": [
              {
                "package": "Kingfisher",
                "repositoryURL": "https://github.com/onevcat/Kingfisher",
                "state": {
                  "branch": null,
                  "revision": "1339ebea9498ef6c3fc75cc195d7163d7c7167f9",
                  "version": "5.14.1"
                }
              },
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
