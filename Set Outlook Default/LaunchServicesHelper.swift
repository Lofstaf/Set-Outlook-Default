//
//  LaunchServicesHelper.swift
//  Set Outlook Default
//
//  Created by Micke on 2025-09-15.
//

import Foundation
import ApplicationServices
import UniformTypeIdentifiers

enum OutlookDefaults {
    struct Current {
        let mailto: String?
        let eml: String?
        let rfc822: String?
    }

    static func outlookBundleID() -> String? {
        let candidates = [
            "com.microsoft.Outlook",      // Outlook (App Store / direct)
            "com.microsoft.OutlookBeta", // Beta variant (rare)
            "com.microsoft.Outlook.dev"  // Dev variant (rare)
        ]
        for id in candidates {
            if let urls = LSCopyApplicationURLsForBundleIdentifier(id as CFString, nil)?.takeRetainedValue() as? [NSURL], !urls.isEmpty {
                return id
            }
        }
        return nil
    }

    @discardableResult
    static func setMailto(bundleID: String) throws -> OSStatus {
        let status = LSSetDefaultHandlerForURLScheme("mailto" as CFString, bundleID as CFString)
        if status != noErr {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Failed to set default handler for mailto (status: \(status))"])
        }
        return status
    }

    @discardableResult
    static func setDefaultHandler(for utType: UTType, role: LSRolesMask = .all, bundleID: String) throws -> OSStatus {
        let status = LSSetDefaultRoleHandlerForContentType(utType.identifier as CFString, role, bundleID as CFString)
        if status != noErr {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Failed to set handler for \(utType.identifier) (status: \(status))"])
        }
        return status
    }

    static func setEMLHandlers(bundleID: String) throws {
        var lastError: Error?
        if let eml = UTType(filenameExtension: "eml") {
            do { try setDefaultHandler(for: eml, role: .all, bundleID: bundleID) } catch { lastError = error }
        }
        if let rfc = UTType(mimeType: "message/rfc822") {
            do { try setDefaultHandler(for: rfc, role: .all, bundleID: bundleID) } catch { lastError = error }
        }
        if let err = lastError { throw err }
    }

    static func currentHandlers() -> Current {
        let mailto = LSCopyDefaultHandlerForURLScheme("mailto" as CFString)?.takeRetainedValue() as String?
        var emlHandler: String? = nil
        var rfcHandler: String? = nil
        if let eml = UTType(filenameExtension: "eml") {
            emlHandler = LSCopyDefaultRoleHandlerForContentType(eml.identifier as CFString, .all)?.takeRetainedValue() as String?
        }
        if let rfc = UTType(mimeType: "message/rfc822") {
            rfcHandler = LSCopyDefaultRoleHandlerForContentType(rfc.identifier as CFString, .all)?.takeRetainedValue() as String?
        }
        return Current(mailto: mailto, eml: emlHandler, rfc822: rfcHandler)
    }
}
