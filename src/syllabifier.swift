// scanner: syllabifier.swift: A struct that syllabifies input text.
// Copyright (C) 2021 Latinology
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

/// A struct containing a set of functions for the syllabification of Latin words.
public struct Syllabifier {
    private init() {}
    
    /// Indicates whether the consonant is a Latin long vowel.
    ///
    /// - Parameter character: The character to be checked
    public static func isLongVowel(_ character: Character) -> Bool {
        return [
            "ā", "ē", "ō", "ī", "ū", "ȳ",
            "Ā", "Ē", "Ō", "Ī", "Ū", "Ȳ"
        ].contains(character)
    }
    
    /// Indicates whether the consonant is a Latin vowel.
    ///
    /// - Parameter character: The character to be checked
    public static func isVowel(_ character: Character) -> Bool {
        return [
            "a", "ā", "e", "ē", "o", "ō", "i", "ī", "u", "ū", "y", "ȳ",
            "A", "Ā", "E", "Ē", "O", "Ō", "I", "Ī", "U", "Ū", "Y", "Ȳ"
        ].contains(character)
    }
    
    internal static func startsWithVowel(_ string: String) -> Bool {
        return (string.first.map { 
            Syllabifier.isVowel($0)
        } ?? false) && !((string.first == "i" || string.first == "I") 
                        && string.dropFirst().first.map { 
                            Syllabifier.isVowel($0) 
                        } ?? false)
    }
    
    internal static func startsWithScanConsonant(_ string: String) -> Bool {
        // - Not a vowel
        // - H does not count
        return !startsWithVowel(string) && string.first != "h" && string.first != "H"
    }
    
    /// Indicates whether the consonant is a Latin character.
    ///
    /// - Parameter character: The character to be checked
    public static func isConsonant(_ character: Character) -> Bool {
        return character.asciiValue.map { 
            ((65 ..< 90).contains($0) || (97 ..< 123).contains($0)) 
                && (character != "w" || character != "W")
        } ?? false && !Syllabifier.isVowel(character)
    }
    
    /// Indicates whether the vowel pair forms a Latin diphthong.
    ///
    /// - Parameter first: The first vowel in the pair
    /// - Parameter second: The second vowel in the pair
    public static func formsDiphthong(_ first: Character, _ second: Character) -> Bool {
        switch (first, second) {
        case ("a", "e"): return true
        case ("a", "u"): return true
        case ("e", "i"): return true
        case ("e", "u"): return true
        case ("o", "e"): return true
        default:         return false
        }
    }
    
    /// Splits a double consonant.
    ///
    /// - Parameter consonant: The character to be split
    /// - Returns: A tuple of two characters, representing the supposed component parts of the double consonant. If the consonant cannot be split, `nil` will be returned.
    public static func splitConsonant(_ consonant: Character) -> (Character, Character)? {
        switch consonant.asciiValue {
        case 88, 120: // x, X
            return ("c", "s")
        default:
            return nil
        }
    }
    
    /// Indicates whether the given string is a transliteration of a Greek letter.
    ///
    /// - Parameter value: The string to be tested
    /// - Note: The function considers the letter combinations 'th', 'ch', 'kh', 'ph', 'ps' and 'rh' to count as Greek letter translitations.
    public static func isGreekLetter(_ value: String) -> Bool {
        switch value {
        case "th", "ch", "kh" /* (sometimes seen) */, "ph", "ps", "rh":
            return true
        default:
            return false
        }
    }
    
    public static func isLiquid(_ character: Character) -> Bool {
        return ["r", "R", "l", "L"].contains(character)
    }
    
    /// Represents a syllable component.
    ///
    /// - `value`: The contents of the syllable 
    /// - `isLong`: Whether or not the syllable is long. A value of `nil` specifies that it could go either way.
    public typealias Syllable = (value: String, isLong: Bool?)
    
    /// Indicates whether the syllable is open.
    ///
    /// - Note: Open syllables, as contrasted to closed syllables, are those which end with a vowel or diphthong.
    /// - Parameter syllable: The syllable to be checked
    public static func isOpen(_ syllable: Syllable) -> Bool {
        return syllable.value.last.map { Syllabifier.isVowel($0) } ?? false
    }
    
    /// Syllabifies the given Latin word, assuming all macrons are provided.
    ///
    /// - Warning: If the word contains a consonantal 'i', a few tricks will be attempted to derive such consonants, but ultimately it is not a perfect system and 'j' must be used for completely accurate results.
    /// - Parameter word: The given word to be syllabified in accordance with the Latin rules. It is assumed that macrons are properly written, as a dictionary is not embedded which would enable long vowel derivation. 
    /// - Returns: An array of `Syllable` tuples. See there for more information.
    public static func syllabify(word: String) -> [Syllable] {
        var syllables = [Syllable]()
        var syllable = ""
        
        // Iterate through word to extract character sequences that compose syllables
        var index = word.startIndex
        
        // A helper function to peek at the next character in the stream
        func next() -> Character? {
            let nextIndex = word.index(after: index)
            return nextIndex < word.endIndex ? word[nextIndex] : nil
        }
        
        // A helper function to peek at the nth character from now in the stream
        func peek(_ n: Int) -> Character? {
            guard let peekIndex = word.index(index, offsetBy: n, limitedBy: word.endIndex) else {
                return nil
            }
            return peekIndex < word.endIndex ? word[peekIndex] : nil
        }
        
        // A helper function to determine if the nth character from now is a consonantal 'i'
        func peekIsConI(_ n: Int) -> Bool {
            let current = peek(n)
            guard current == "i" || current == "I" else {
                return false
            }
            
            // Next letter must be a vowel
            guard peek(n + 1).map { Syllabifier.isVowel($0) } ?? false else {
                return false
            }
            
            let third = peek(n + 2)
            
            // There is no clear indicator of consonantal 'i', and as such this syllabifier will not be perfect when encountering such scenarios. For perfect handling prefer to use 'j'. However there are some general rules we can use:
            // * 'jaciō'
            //   * even with compounds like ob-, sub-, ē-, ... (e.g. 'adjectīvum')
            // * a starting ju-, ji-, je-
            // * the exclamation 'jō'
            // * j will tend to not be in a last syllable
            
            if index == word.startIndex {
                // If it is starting the word, it usually is consonantal
                return true
            } else if index > word.startIndex, peek(n - 1).map { Syllabifier.isVowel($0) } ?? false {
                // If it is preceded by a vowel, then it is a double consonantal 'i'
                // TODO: find some way to indicate this
                return true
            } else if third == "c" || third == "C" {
                // Probably a compound or iaciō itself
                return true
            } else {
                // In most other cases it tends to be a vowel
                return false
            }
        }
        
        // A helper function that indicates if the next character is a vowel, taking consonantal 'i's into account
        func peekIsVowel(_ n: Int) -> Bool {
            return peek(n).map { Syllabifier.isVowel($0) } ?? false && !peekIsConI(n)
        }
        
        // The state of the syllabifier, representing the type of syllable that currently is being parsed
        enum State {
            case idle, monophthong, longMonophthong, diphthong
        }
        var state = State.idle
        
        while index < word.endIndex {
            let current = word[index]
            
            if Syllabifier.isConsonant(current) || peekIsConI(0) {
                if state != .idle {
                    // If we have already encountered vowel(s), then:
                    // - a single consonant marks the start of the next syllable
                    // - two consonants or a double consonant are split
                    
                    if let (end, start) = Syllabifier.splitConsonant(current) {
                        // If the consonant is a double consonant and then split it
                        syllable.append(end)
                        syllables.append((syllable, isLong: true)) // long by position
                        syllable = "\(start)"
                        
                        // Reset the scanning state to signify that we have begun a new syllable
                        state = .idle
                    } else {
                        // Otherwise we check whether to incorporate it into the current syllable
                        
                        if peekIsVowel(1) {
                            // If the following letter is a vowel, this consonant belongs to the next syllable
                            syllables.append((syllable, isLong: state == .longMonophthong || state == .diphthong))
                            syllable = "\(current)"
                            
                            // Reset the scanning state to signify that we have begun a new syllable
                            state = .idle
                        } else {
                            // If the letter after the next is a vowel
                            if peekIsVowel(2) {
                                // Liquids can make syllable length go either way
                                // We split on this syllable before adding if it is a liquid
                                if next().map { Syllabifier.isLiquid($0) } ?? false && current != next() {
                                    syllables.append((syllable, isLong: next() != current ? nil : true))               
                                    syllable = "\(current)"
                                } else {
                                    syllable.append(current)
                                    syllables.append((syllable, isLong: true)) // long by position
                                    syllable.removeAll()
                                    
                                }
                                
                                // Reset the scanning state to signify that we have begun a new syllable
                                state = .idle
                            } else {
                                // If the following letter is a consonant and there are no upcoming vowels, the current letter will belong to this syllable
                                syllable.append(current)
                                
                                if next() == nil {
                                    syllables.append((syllable, syllable.dropLast().last.map {
                                        Syllabifier.isConsonant($0) 
                                    } ?? false)) // long by position
                                    syllable.removeAll()
                                }
                            }
                        }
                    }
                } else {
                    // Otherwise, we simply append the consonant to the syllable
                    syllable.append(current)
                }
            } else if Syllabifier.isVowel(current) {
                switch state {
                case .idle:
                    // Have not yet encountered vowel, add and mark unless it's a 'u' after 'q'
                    if !((syllable.last == "q" || syllable.last == "Q") 
                        && (current == "u" || current == "U")) {
                        state = Syllabifier.isLongVowel(current) ? .longMonophthong : .monophthong
                    }
                    
                    syllable.append(current)
                case .monophthong, .longMonophthong:
                    // Latin diphthongs are: ae, au ei, eu and oe
                    if let last = syllable.last, Syllabifier.formsDiphthong(last, current) {
                        syllable.append(current)
                        state = .diphthong
                    } else {
                        // Vowel-ending syllable; append and move on, resetting state
                        let lastIsLong = syllable.last.map { Syllabifier.isLongVowel($0) } ?? false
                        syllables.append((syllable, isLong: lastIsLong)) 
                        syllable = "\(current)"
                        state = Syllabifier.isLongVowel(current) ? .longMonophthong : .monophthong
                    }
                case .diphthong:
                    // No triphthongs exist in Latin; start of new syllable
                    syllable.append(current)
                    syllables.append((syllable, isLong: true)) // diphtongs long
                    syllable.removeAll()
                    state = Syllabifier.isLongVowel(current) ? .longMonophthong : .monophthong
                }
            } else {
                // Invalid word, eject nothing
                // FIXME: with better handling for this case
                return []
            }
            
            // If there is no next character, we will just move out of the loop
            if next() == nil {
                break
            }
            
            
            // Advance to the next letter
            word.formIndex(after: &index)
        }
        
        // If we have terminated then confirm that we are not ending without the last syllable
        if !syllable.isEmpty {
            syllables.append((syllable, isLong: state == .longMonophthong || state == .diphthong))
        }
        
        return syllables
    }
}
