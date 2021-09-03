// scanner: tests.swift: Testing functions for the syllabifier and scanner.
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

public struct SyllabifierTests {
    private init() {}
    
    public enum TestType: Int, CustomStringConvertible {
        case doubleConsonants
        case consecConsonants
        case consecVowels
        case consonantalI
        case fauxConsonantalI
        case endingConsonant
        case endingVowel
        case quCombs
        case diphthongs
        case fauxDiphthongs
        
        public var description: String {
            switch self {
            case .doubleConsonants:
                return "double consonants"
            case .consecConsonants:
                return "consecutive consonants"
            case .consecVowels:
                return "consecutive vowels"
            case .consonantalI:
                return "consonantal I"
            case .fauxConsonantalI:
                return "faux consonantal I"
            case .endingConsonant:
                return "ending consonant"
            case .endingVowel:
                return "ending vowel"
            case .diphthongs:
                return "diphthongs"
            case .fauxDiphthongs:
                return "faux diphthongs"
            case .quCombs:
                return "'qu' combinations"
            default:
                return ""
            }
        }
        
        case end
    }
    
    public static func test(_ tester: @escaping ((String, [String], [TestType]) -> ()) -> ()) -> () -> () {
        return {
            print("➡️ Testing Syllabifier...")
            var correct = 0
            var total = 0
            var problems = [Int](repeating: 0, count: TestType.end.rawValue)
            
            func testFunc(_ word: String, _ target: [String], _ testType: [TestType]) {
                total += 1
                let result = Syllabifier.syllabify(word: word)
                if result.map { $0.value } == target {
                    print("  ✅ Correctly syllabified '\(word)'")
                    correct += 1
                } else {
                    print("  ❌ Failed to syllabify '\(word)'")
                    testType.forEach {
                        problems[$0.rawValue] += 1
                    }
                }
                print("     Produced: \(result.map { "\($0.0)(\($0.1 == nil ? "?" : ($0.1! ? "-" : "u")))" }.joined(separator: " "))")
                
            }
            
            tester(testFunc)
            
            print("⬅️ Passed with a score of \(Int(Double(correct) / Double(total) * 100))% (\(correct)/\(total))")
            if problems.contains { $0 > 0 } {
                print("   Problems:")
                for (index, problem) in problems.enumerated().sorted(by: { $0.1 > $1.1 }) where problem > 0 {
                    print("   - \(Int(Double(problem) / Double(total - correct) * 100))% of failures included \(TestType(rawValue: index)!)")
                }
            }
        }
    }
    
}

public struct ScannerTests {
    private init() {}
    
    public static func dumpScan(line: String) {
        let components = line.split(omittingEmptySubsequences: true) { 
            " ,.:;\"'()[]-_=+/\\`~".contains($0) 
        }.map { String($0) }
        let results = Scanner.scan(line: components, elide: false)
        print(results.map { $0.map { $0.value }.joined() }.joined(separator: " "))
        for result in results {
            for syllable in result {
                switch syllable.isLong {
                case .some(true): 
                    print("-", terminator: "")
                case .some(false): 
                    print("u", terminator: "")
                case nil: 
                    print("?", terminator: "")
                }
                print(String(repeating: " ", count: syllable.value.count - 1), terminator: "")
            }
            print(" ", terminator: "")
        }
        print()
        print("The line is", Scanner.match(line: results, against: .hexameter) ? "✅ valid" : "❌ invalid", "hexameter")
        print()
    }
}
