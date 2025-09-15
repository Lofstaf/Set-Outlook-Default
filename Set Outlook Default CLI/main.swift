//
//  main.swift
//  Set Outlook Default CLI
//
//  Created by Micke on 2025-09-15.
//

import Foundation



struct Main {
static func main() {
guard let id = OutlookDefaults.outlookBundleID() else {
fputs("Outlook not found
", stderr); exit(1)
}
do {
try OutlookDefaults.setMailto(bundleID: id)
try OutlookDefaults.setEMLHandlers(bundleID: id)
print("OK")
} catch {
fputs("Error: \(error)
", stderr); exit(2)
}
}
}
