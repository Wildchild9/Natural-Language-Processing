//
//  String Extensions.swift
//  Natural Language Processing
//
//  Created by Noah Wilder on 2019-03-15.
//  Copyright © 2019 Noah Wilder. All rights reserved.
//

import Foundation
import NaturalLanguage

public extension StringProtocol {
    
    /// An array containing the words in the string.
    var words: [Word] {
        let str = String(self)
        let languageRecognizer = NLLanguageRecognizer()
        languageRecognizer.processString(str)
        let dominantLanguage = languageRecognizer.dominantLanguage
        let language: Language? = dominantLanguage == nil ? nil : Language(nlLanguage: dominantLanguage!)
        
        
        
        let tagger = NLTagger(tagSchemes: [.tokenType])
        let stringRange = str.startIndex..<str.endIndex
        let options: NLTagger.Options = [.joinContractions, .joinNames, .omitOther, .omitPunctuation, .omitWhitespace]
        
        tagger.string = str
        let tags = tagger.tags(in: stringRange, unit: .word, scheme: .tokenType, options: options)
        
        var words = [Word]()
        words.reserveCapacity(tags.count)
        
        for case let (tag?, range) in tags where tag == .word  {
            guard var word = Word(str[range]) else { continue }
            if let language = language {
                word.language = language
            }
            words.append(word)
        }
        
        return words
    }
    
    /// Enumerates the words in the specified range of the string.
    ///
    /// - Parameters:
    ///   - range: The range within the string to enumerate words.
    ///   - body: The closure executed for each word in the enumeration. The
    ///     closure takes four arguments:
    ///   - word: The enumerated word.
    ///   - wordRange: The range of the enumerated word in the string that
    ///     `enumerateWords(in:_:)` was called on.
    ///   - stop: An `inout` Boolean value that the closure can use to stop the
    ///     enumeration by setting `stop = true`.
    
    func enumerateWords(in range: Range<Index>, _ body: @escaping (_ wordRange: Range<SubSequence.Index>, _ word: Word, _ stop: inout Bool) -> Void) {
        let str = String(self)
        let tagger = NLTagger(tagSchemes: [.tokenType])
        let stringRange = str.startIndex..<str.endIndex
        let options: NLTagger.Options = [.joinContractions, .joinNames, .omitOther, .omitPunctuation, .omitWhitespace]
        
        tagger.string = str
        
        var stop = false
        tagger.enumerateTags(in: stringRange, unit: .word, scheme: .tokenType, options: options) { (tag, tagRange) -> Bool in
            guard let wordTag = tag, wordTag == .word else { return stop }
            
            let substringRange = index(startIndex, offsetBy: tagRange.lowerBound.utf16Offset(in: str))..<index(startIndex, offsetBy: tagRange.upperBound.utf16Offset(in: str))
            
            guard let word = Word(self[substringRange]) else { return !stop }
            body(substringRange, word, &stop)
            
            return !stop
        }
       
    }
    
    /// Enumerates the words in the string.
    ///
    /// - Parameters:
    ///   - body: The closure executed for each word in the enumeration. The
    ///     closure takes four arguments:
    ///     - The enumerated word.
    ///     - The range of the enumerated word in the string that
    ///       `enumerateWords(in:_:)` was called on.
    ///     - An `inout` Boolean value that the closure can use to stop the
    ///       enumeration by setting `stop = true`.
    func enumerateWords(_ body: @escaping (Range<SubSequence.Index>, Word, inout Bool) -> Void) {
        enumerateWords(in: startIndex..<endIndex, body)
    }
    
    /// The definition of a string, or `nil` if the definition cannot be found.
    var definition: String? {
        let nsstring = String(self) as NSString
        let cfrange = CFRange(location: 0, length: nsstring.length)
        guard let definition = DCSCopyTextDefinition(nil, nsstring, cfrange) else { return nil }
        return String(definition.takeUnretainedValue())
    }
}

