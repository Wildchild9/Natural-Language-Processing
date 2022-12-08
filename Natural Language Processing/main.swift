//
//  main.swift
//  Natural Language Processing
//
//  Created by Noah Wilder on 2019-03-14.
//  Copyright © 2019 Noah Wilder. All rights reserved.
//

import Foundation
import NaturalLanguage
import Cocoa


let quote = "Here's to the crazy ones. The misfits. The rebels. The troublemakers. The round pegs in the square holes. The ones who see things differently. They're not fond of rules. And they have no respect for the status quo. You can quote them, disagree with them, glorify or vilify them. About the only thing you can't do is ignore them. Because they change things. They push the human race forward. And while some may see them as the crazy ones, we see genius. Because the people who are crazy enough to think they can change the world, are the ones who do. -Steve Jobs (Founder of Apple Inc.)"

print(Word("Democratization")!.definition!)
print()

let s = Word("Democracy", language: .english)!.correctingSpelling()
print(s.definition!)



let string = "tyme"
var w = Word(string)!
w.language = .english
print(w.languageGuesses())
print(w.isSpelledCorrectly)
print(w.spellCheckGuesses())
w = w.correctingSpelling()
print(w)


print(Word("fundmntally", language: .english)!.correctingSpelling().partOfSpeech!)
print(Word("מידחסויחסדפבהדו")!.isSpelledCorrectly)

func פרינת(_ דברים: Any..., separator: String = " ", terminator: String = "\n") {
    print(דברים.map { "\($0)" }.joined(separator: separator), separator: "", terminator: terminator)
}


//spellChecker.setLanguage(w.language.name)
//print(word.string[Range(spellChecker.checkSpelling(of: w.string, startingAt: 0), in: w.string)!])
//print(spellChecker.checkSpelling)

//let spellServer = NSSpellServer()
//var wordCount = 1
//let results = spellServer.delegate!.spellServer!(spellServer, check: str, offset: 0, types: NSTextCheckingAllSystemTypes, options: nil, orthography: nil, wordCount: &wordCount)
//spellServer.run()
dump(w)
dump([12,312,312], name: "playground")
dump(["hello":1, "fuck": 234])
dump((key: "hello", value: 1))

class OtherThing: CustomStringConvertible {
    var description: String {
        return "Some class"
    }
}
class Car: OtherThing {
    var color: String
    
    init (color: String) {
        self.color = color
    }
}
class Toyota: Car {
    var brandName: String = "Toyota"
    
    var lowercased: String {
        return brandName.lowercased()
    }
    
    
    class Thing {
        var insideThing: String
        
        init (insideThing: String) {
            self.insideThing = insideThing
        }
    }
    
    override var description: String {
        return color.capitalized + " " + brandName
    }
}

dump(stride(from: 4, to: 10, by: 2))
debugPrint(stride(from: 4, to: 10, by: 2))


var car = Toyota(color: "red")
dump(car)
enum Planet {
    case mercury, earth, venus
}
dump(Planet.earth)

dump(Toyota.self)

class Stuff: CustomStringConvertible {
    var description: String {
        return "Really?!"
    }
}

dump(Stuff())

dump(("ABC", 100))

var thing: String? = nil
dump(thing)
var maybeCar: Toyota? = Toyota(color: "red")
dump(maybeCar)
var maybeNumber: Set<Int>? = Set(1...9)
dump(maybeNumber)

public extension String.StringInterpolation {
    mutating func appendInterpolation(repeating repeatedValue: String, count: Int) {
        appendLiteral(String(repeating: repeatedValue, count: count))
    }
    mutating func appendInterpolation(repeating repeatedValue: Character, count: Int) {
        appendLiteral(String(repeating: repeatedValue, count: count))
    }
}

print("\(repeating: " ̶", count: 100)")

var word = Word("Again")!
print(word.partOfSpeech!)
//
//var words = ["Limas": "crying", "Angos": "biting", "Idakos": "attacking", "Liris": "smiling", "Bardus": "writing", "Merbus": "hungry", "Vujis": "kissing", "Sindis": "buying", "Urnes": "seeing", "Kelis": "stopping", "Arli": "again", "Ropas": "falling", "Pilos": "holding", "Iotaptes": "respect", "Ipradas": "eating", "Qintir": "turtle", "Kēli": "cat", "Jaohossa": "dog", "Sylvi": "wise", "Syz": "good", "Kirine": "happy", "Nages": "sweating", "Kelia": "lion", "Atroksie": "owl", "Aeksio": "master", "Raqiros": "friend", "Daeri": "free", "Kostoba": "powerful", "Demarion": "throne", "Zokla": "wolf", "Nektos": "cutting", "Korze": "sword", "Arghus": "hunting", "Edrus": "sleeping", "Jorraelza": "loves", "Izugas": "fears", "Rybas": "hears", "Anogra": "blood", "Zaldrizes": "dragon", "Darys": "king", "Jaes": "god", "Jentys": "leader", "Zentys": "guest"]
//for word in words.values.compactMap(Word.init) {
//    print("\(word): \(word.partOfSpeech?.description ?? "Unknown")")
//}

extension String {
    var partOfSpeech: String {
        return Word(self)!.partOfSpeech!.description
    }
}

print("Welcome".partOfSpeech)
print(String(repeating: "-", count: 100))
var axiom = Word("Axiom")!
print(axiom.definition!)
print(axiom.partOfSpeech!)
print(axiom.lemma!)
print(axiom.language)



