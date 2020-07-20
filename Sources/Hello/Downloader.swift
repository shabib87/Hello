//
//  Downloader.swift
//  Created by Shabib Hossain on 2020-07-19.
//

import Foundation

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
