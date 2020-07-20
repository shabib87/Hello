import Darwin
import Foundation
import Combine

let fileManager = FileManager.default

enum SessionError: Error {
    case statusCode(HTTPURLResponse)
}

var cancellable: AnyCancellable?


//getLicenseFromLocalSPM()
//getLicensenseFromCocopod()
//getLicenseFromXcodeManagedSPM()
TestLicenseDownload().testing()
