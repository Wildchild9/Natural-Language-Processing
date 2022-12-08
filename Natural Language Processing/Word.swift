//
//  Word.swift
//  Natural Language Processing
//
//  Created by Noah Wilder on 2019-03-14.
//  Copyright © 2019 Noah Wilder. All rights reserved.
//

import Foundation
import NaturalLanguage
import Cocoa

public struct Word {
    
    //Mark: Stored Properties
    
    private var word: String {
        didSet {
            tagger.string = word
        }
    }
    
    /// The string of the word.
    public var string: String {
        return word
    }
    
    
    /// The language of the word.
    public var language: Language {
        didSet {
            tagger.setLanguage(language.nlLanguage, range: range)
            spellChecker.setLanguage(language.identifier)
        }
    }
    
    private let tagger: NLTagger
    private let spellChecker: NSSpellChecker
    
    private let taggerOptions: NLTagger.Options = [.joinContractions, .joinNames, .omitOther, .omitPunctuation, .omitWhitespace]
    
    //MARK: Initializer
    
    /// Create a word from the given string of the specified language. Returns `nil` if the word is invalid.
    public init?<T: StringProtocol>(_ string: T, language: Language) {
        let str = String(string)
        
        tagger = NLTagger(tagSchemes: [.tokenType, .lexicalClass, .nameType, .nameTypeOrLexicalClass, .lemma, .language, .script])
        tagger.string = str
        
        let tags = tagger.tags(in: str.startIndex..<str.endIndex, unit: .word, scheme: .tokenType, options: taggerOptions)
        
        guard tags.count == 1, let tag = tags.first, tag.0 == .word else { return nil }
        
        word = String(str[tag.1])
        tagger.string = word
        
        self.language = language
        
        spellChecker = NSSpellChecker()
        spellChecker.setLanguage(language.identifier)
        
        tagger.setLanguage(language.nlLanguage, range: range)
        
    }
    

    // Private Computed Properties
    private var range: Range<String.Index> {
        return word.startIndex..<word.endIndex
    }
}



//┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃ MARK: - Initializers

public extension Word {
    /// Create a word from the given string. Returns `nil` if the word is invalid.
    init?<T: StringProtocol>(_ string: T) {
        let str = String(string)
        
        tagger = NLTagger(tagSchemes: [.tokenType, .lexicalClass, .nameType, .nameTypeOrLexicalClass, .lemma, .language, .script])
        tagger.string = str
        
        let tags = tagger.tags(in: str.startIndex..<str.endIndex, unit: .word, scheme: .tokenType, options: taggerOptions)
        
        guard tags.count == 1, let tag = tags.first, tag.0 == .word else { return nil }
        
        word = String(str[tag.1])
        tagger.string = word
        
        guard let languageOfWord = Language(of: word) else { return nil }
        language = languageOfWord
        
        spellChecker = NSSpellChecker()
        spellChecker.setLanguage(language.identifier)
        
        tagger.setLanguage(language.nlLanguage, range: range)
        
        
    }
}




//┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃ MARK: - Computed Properties

public extension Word {

    
    /// The stem of the word, or `nil` if it is unknown.
    var lemma: String? {
        let tags = tagger.tags(in: range, unit: .word, scheme: .lemma, options: taggerOptions)
        guard tags.count == 1, let lemma = tags[0].0 else {
            return nil
        }
        return lemma.rawValue
    }
    
    /// The part of speech of the word, or `nil` if it is unknown.
    var partOfSpeech: PartOfSpeech? {
        let tags = tagger.tags(in: range, unit: .word, scheme: .lexicalClass, options: taggerOptions)
        guard tags.count == 1, let partOfSpeech = tags[0].0 else {
            return nil
        }
        return PartOfSpeech(tag: partOfSpeech)
    }
    
    /// Classifies the word according to whether it is part of a named entity, or `nil` if it isn't.
    var nameType: NameType? {
        let tags = tagger.tags(in: range, unit: .word, scheme: .lexicalClass, options: taggerOptions)
        guard tags.count == 1, let nameType = tags[0].0 else {
            return nil
        }
        return NameType(tag: nameType)
    }
    
    /// Classifies the word according to `nameType` if it corresponds to a name, otherwise it classifies the word according to its `partOfSpeech`.
    var nameTypeOrPartOfSpeech: NameTypeOrPartOfSpeech? {
        let tags = tagger.tags(in: range, unit: .word, scheme: .nameTypeOrLexicalClass, options: taggerOptions)
        guard tags.count == 1, let nameTypeOrPartOfSpeech = tags[0].0 else {
            return nil
        }
        return NameTypeOrPartOfSpeech(tag: nameTypeOrPartOfSpeech)
    }
    
    /// Best language guess for the word.
    var languageGuess: Language? {
        let languageRecognizer = NLLanguageRecognizer()
        languageRecognizer.processString(word)
        guard let dominantLanguage = languageRecognizer.dominantLanguage else {
            return nil
        }
        return Language(nlLanguage: dominantLanguage)
    }
}


//┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃ MARK: - Letter Case
//public extension Word {
//    
//    var capitalized: String {
//        return string.localizedCapitalized
//    }
//}

//┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃ MARK: - Spell Checking
public extension Word {
    
    /// Returns `true` if the word is spelled correctly, otherwise returns `false`.
    var isSpelledCorrectly: Bool {
        
        let check = spellChecker.checkSpelling(of: string, startingAt: 0)
        return check.lowerBound == NSNotFound
    }
    
    /// Corrects the spelling of the word.
    mutating func correctSpelling() {
        guard let correction = spellChecker.correction(forWordRange: NSRange(range, in: string), in: string, language: language.identifier, inSpellDocumentWithTag: 0) else {
            return
        }
        self.word = correction
    }
    
    /// Returns the word with its spelling corrected.
    func correctingSpelling() -> Word {
        var correctedWord = self
        correctedWord.correctSpelling()
        return correctedWord
    }
    
    /// Spell check guesses for the word.
    func spellCheckGuesses() -> [Word] {
        guard let guesses = spellChecker.guesses(forWordRange: NSRange(range, in: string), in: string, language: language.identifier, inSpellDocumentWithTag: 0) else {
            return []
        }
        return guesses.map { Word($0, language: language)! }
    }
    
    /// Completions for the word.
    func completions() -> [Word] {
        guard let completions = spellChecker.completions(forPartialWordRange: NSRange(range, in: string), in: string, language: language.identifier, inSpellDocumentWithTag: 0) else {
            return []
        }
        return completions.map { Word($0, language: language)! }
    }
}

//#if os(iOS)
//import UIKit
//extension String {
//    var thing: Int {
//        let checker = UITextChecker()
//        return 2
//    }
//}
//#else
//import Cocoa
//extension String {
//    var thing: Int {
//        let checker = NSSpellChecker()
//        return 2
//    }
//}
//#endif

//┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃ MARK: - Methods
public extension Word {
    
    /// A specified number of language guesses and their associated certainties for the word.
    func languageGuesses(maxGuesses: Int = 10) -> [(language: Language, certainty: Double)]  {
        guard maxGuesses > 0 else {
            return [(language: Language, certainty: Double)]()
        }
        let languageRecognizer = NLLanguageRecognizer()
        languageRecognizer.processString(word)
        let languageHypotheses = languageRecognizer.languageHypotheses(withMaximum: maxGuesses)
        
        return languageHypotheses.map { (language: Language(nlLanguage: $0.key), certainty: $0.value * 100) }.sorted { $0.certainty > $1.certainty }
    }
    
}

//┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃ MARK: - Definition Computed Property

public extension Word {
    
    /// The definition of the word, or `nil` if the definition is unknown or can't be found.
    var definition: String? {
        let nsstring = word as NSString
        let cfrange = CFRange(location: 0, length: nsstring.length)
        guard let definitionText = DCSCopyTextDefinition(nil, nsstring, cfrange) else {
            return nil
        }
        
        let defStr = String(definitionText.takeUnretainedValue())
        var formattedDefinition = ""
        
        var definitions = [String]()
        
        let definitionInfoRegex = try! NSRegularExpression(pattern: "^(?i)(?<word>\(string))\\s(?<wordInfo>(?:(?:\\|\\s(?:.+?\\s\\|\\s)+)?)(?:(?:(?:\\(.+?\\)\\s)|(?:\\[.+?\\]\\s))+)?)?(?<partOfSpeech>(?:noun|verb|adjective|adverb|pronoun|determiner|particle|preposition|number|conjunction|interjection|classifier|idiom)\\s(?:(?:(?:\\(.+?\\)\\s)|(?:\\[.+?\\]\\s))+)?).+")
        guard let match = definitionInfoRegex.firstMatch(in: defStr, range: NSRange(defStr.startIndex..., in: defStr)) else {
            return nil
        }
        
        guard let range1 = Range(match.range(withName: "word"), in: defStr) else {
            return nil
        }
        let wordBeingDefined = String(defStr[range1])
        formattedDefinition.append(wordBeingDefined + "\n")
        
        if let range2 = Range(match.range(withName: "wordInfo"), in: defStr) {
            let wordInfo = String(defStr[range2])
            if !wordInfo.isEmpty {
                formattedDefinition.append(" " + wordInfo + "\n")
            }
        }
        
        guard let range3 = Range(match.range(withName: "partOfSpeech"), in: defStr) else {
            return nil
        }
        let wordPartOfSpeech = String(defStr[range3])
        formattedDefinition.append(" " + wordPartOfSpeech + "\n")
        
        
        let definitionsRegex = try! NSRegularExpression(pattern: "(?<=\\s|^)(\\d+\\s.+?)(?=(?:\\s\\d+\\s|$))")
        
        let definitionsSection = String(defStr[range3.upperBound...])
        let matches = definitionsRegex.matches(in: definitionsSection, range: NSRange(definitionsSection.startIndex..., in: definitionsSection))
        if !matches.isEmpty {
            for match in matches where match.range.lowerBound != NSNotFound {
                
                let definition = String(definitionsSection[Range(match.range, in: definitionsSection)!])
                definitions.append(definition)
            }
        } else {
            definitions.append(String(definitionsSection))
        }
        
        formattedDefinition.append("\t" + definitions.map {
            $0.replacingOccurrences(of: " • ", with: "\n\t\t• ")
                .replacingOccurrences(of: "^(\\d+)", with: "$1.", options: .regularExpression)
            }.joined(separator: "\n\t"))
        
        return formattedDefinition
    }
}

//┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃ MARK: - NameTypeOrPartOfSpeech

public extension Word {
    
    /// The name type or part of speech of the word.
    enum NameTypeOrPartOfSpeech {
        case nameType(NameType)
        case partOfSpeech(PartOfSpeech)
        
        /// The corresponding `NLTag` to the `NameType` or `PartOfSpeech`.
        var nlTag: NLTag {
            switch self {
            case .partOfSpeech(.noun): return .noun
            case .partOfSpeech(.verb): return .verb
            case .partOfSpeech(.adjective): return .adjective
            case .partOfSpeech(.adverb): return .adverb
            case .partOfSpeech(.pronoun): return .pronoun
            case .partOfSpeech(.determiner): return .determiner
            case .partOfSpeech(.particle): return .particle
            case .partOfSpeech(.preposition): return .preposition
            case .partOfSpeech(.number): return .number
            case .partOfSpeech(.conjunction): return .conjunction
            case .partOfSpeech(.interjection): return .interjection
            case .partOfSpeech(.classifier): return .classifier
            case .partOfSpeech(.idiom): return .idiom
            case .partOfSpeech(.otherWord): return .otherWord
            case .nameType(.personalName): return .personalName
            case .nameType(.organizationName): return .organizationName
            case .nameType(.placeName): return .placeName
            }
        }
        
        /// Create a new `NameType` or  `PartOfSpeech` from their corresponding `NLTag`, or `nil` if the `NLTag` is not a name type or part of speech.
        init? (tag: NLTag) {
            switch tag {
            case .noun: self = .partOfSpeech(.noun)
            case .verb: self = .partOfSpeech(.verb)
            case .adjective: self = .partOfSpeech(.adjective)
            case .adverb: self = .partOfSpeech(.adverb)
            case .pronoun: self = .partOfSpeech(.pronoun)
            case .determiner: self = .partOfSpeech(.determiner)
            case .particle: self = .partOfSpeech(.particle)
            case .preposition: self = .partOfSpeech(.preposition)
            case .number: self = .partOfSpeech(.number)
            case .conjunction: self = .partOfSpeech(.conjunction)
            case .interjection: self = .partOfSpeech(.interjection)
            case .classifier: self = .partOfSpeech(.classifier)
            case .idiom: self = .partOfSpeech(.idiom)
            case .otherWord: self = .partOfSpeech(.otherWord)
            case .personalName: self = .nameType(.personalName)
            case .organizationName: self = .nameType(.organizationName)
            case .placeName: self = .nameType(.placeName)
            default: return nil
            }
        }
    }
}

//┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃ MARK: - NameType

public extension Word {
/// The name type of the word.
    enum NameType: String, CaseIterable {
        case personalName = "PersonalName"
        case organizationName = "OrganizationName"
        case placeName = "PlaceName"
        
        /// The corresponding `NLTag` to the `NameType`.
        var nlTag: NLTag {
            switch self {
            case .personalName: return .personalName
            case .organizationName: return .organizationName
            case .placeName: return .placeName
            }
        }
        
        /// Create a new `NameType` from their corresponding `NLTag`, or `nil` if the `NLTag` is not a name type.
        init? (tag: NLTag) {
            switch tag {
            case .personalName: self = .personalName
            case .organizationName: self = .organizationName
            case .placeName: self = .placeName
            default: return nil
            }
        }
    }
}


//┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃ MARK: - PartOfSpeech

public extension Word {
    /// The part of speech of the word.
    enum PartOfSpeech: String, CaseIterable {
        case noun = "Noun"
        case verb = "Verb"
        case adjective = "Adjective"
        case adverb = "Adverb"
        case pronoun = "Pronoun"
        case determiner = "Determiner"
        case particle = "Particle"
        case preposition = "Preposition"
        case number = "Number"
        case conjunction = "Conjunction"
        case interjection = "Interjection"
        case classifier = "Classifier"
        case idiom = "Idiom"
        case otherWord = "OtherWord"
        
        /// The corresponding `NLTag` to the `PartOfSpeech`.
        var nlTag: NLTag {
            switch self {
            case .noun: return .noun
            case .verb: return .verb
            case .adjective: return .adjective
            case .adverb: return .adverb
            case .pronoun: return .pronoun
            case .determiner: return .determiner
            case .particle: return .particle
            case .preposition: return .preposition
            case .number: return .number
            case .conjunction: return .conjunction
            case .interjection: return .interjection
            case .classifier: return .classifier
            case .idiom: return .idiom
            case .otherWord: return .otherWord
            }
        }
        
        /// Create a new `PartOfSpeech` from their corresponding `NLTag`, or `nil` if the `NLTag` is not a part of speech.
        init? (tag: NLTag) {
            switch tag {
            case .noun: self = .noun
            case .verb: self = .verb
            case .adjective: self = .adjective
            case .adverb: self = .adverb
            case .pronoun: self = .pronoun
            case .determiner: self = .determiner
            case .particle: self = .particle
            case .preposition: self = .preposition
            case .number: self = .number
            case .conjunction: self = .conjunction
            case .interjection: self = .interjection
            case .classifier: self = .classifier
            case .idiom: self = .idiom
            case .otherWord: self = .otherWord
            default: return nil
            }
        }
    }
}


//┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃ MARK: - CustomStringConvertible Conformances

extension Word: CustomStringConvertible {
    /// A textual representation of `Word`.
    public var description: String {
        return word
    }
}

extension Word.PartOfSpeech: CustomStringConvertible {
    /// A textual representation of `PartOfSpeech`.
    public var description: String {
        switch self {
        case .noun: return "Noun"
        case .verb: return "Verb"
        case .adjective: return "Adjective"
        case .adverb: return "Adverb"
        case .pronoun: return "Pronoun"
        case .determiner: return "Determiner"
        case .particle: return "Particle"
        case .preposition: return "Preposition"
        case .number: return "Number"
        case .conjunction: return "Conjunction"
        case .interjection: return "Interjection"
        case .classifier: return "Classifier"
        case .idiom: return "Idiom"
        case .otherWord: return "Other Word"
        }
    }
}

extension Word.NameType: CustomStringConvertible {
    /// A textual representation of `NameType`.
    public var description: String {
        switch self {
        case .personalName: return "Personal Name"
        case .organizationName: return "Organization Name"
        case .placeName: return "Place Name"
        }
    }
}

extension Word.NameTypeOrPartOfSpeech: CustomStringConvertible {
    
    /// A textual representation of `NameTypeOrPartOfSpeech`.
    public var description: String {
        switch self {
        case let .nameType(nameType):
            return nameType.description
        case let .partOfSpeech(partOfSpeech):
            return partOfSpeech.description
        }
    }
}
