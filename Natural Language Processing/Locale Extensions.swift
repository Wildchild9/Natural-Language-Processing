//
//  Locale Extensions.swift
//  Natural Language Processing
//
//  Created by Noah Wilder on 2019-03-14.
//  Copyright © 2019 Noah Wilder. All rights reserved.
//

import Foundation

public extension Locale {
    static var availableLanguages: [(identifier: String, localizedString: String)] {
        
        return Locale.availableIdentifiers
            .map { identifier -> (identifier: String, localizedString: String) in
                guard let localizedString = current.fullLocalizedString(forIdentifier: identifier) else {
                    fatalError("Invalid locale identifier")
                }
                return (identifier: identifier, localizedString: localizedString)
            }
            .sorted { $0.identifier < $1.identifier }
    }
    
    func fullLocalizedString(forIdentifier isoCode: String) -> String? {
        
        let (languageCodeKey, scriptCodeKey, countryCodeKey, variantCodeKey) = ("kCFLocaleLanguageCodeKey", "kCFLocaleScriptCodeKey", "kCFLocaleCountryCodeKey", "kCFLocaleVariantCodeKey")
        
        let components = Locale.components(fromIdentifier: isoCode)
        var specifications = [String]()
        
        guard let languageCode = components[languageCodeKey], let languageName = self.localizedString(forLanguageCode: languageCode) else  {
            return nil
        }
        
        if let scriptCode = components[scriptCodeKey],
            let scriptIdentifier = self.localizedString(forScriptCode: scriptCode) {
            
            specifications.append(scriptIdentifier)
        }
        
        if let countryCode = components[countryCodeKey],
            let countryIdentifier = self.localizedString(forRegionCode: countryCode) {
            
            specifications.append(countryIdentifier)
        }
        
        if let variantCode = components[variantCodeKey],
            let variantIdentifier = self.localizedString(forVariantCode: variantCode) {
            
            specifications.append(variantIdentifier)
        }
        
        let localizedString: String
        
        if specifications.isEmpty {
            localizedString = languageName
        } else {
            localizedString = "\(languageName) (\(specifications.joined(separator: ", ")))"
        }
        
        return localizedString
    }
}

