// scanner: scanner.swift: A struct that scans input text.
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

/// A struct containing a set of functions for the scanning of Latin text.
public struct Scanner {
    private init() {}
    
    public typealias Syllable = Syllabifier.Syllable
    
    public static func scan(line: [String], elide: Bool) -> [[Syllable]] {
        // Convert words to syllables
        return scan(syllables: line.map {
            Syllabifier.syllabify(word: $0)
        }, elide: elide)
    }
    
    public static func scan(syllables: [[Syllable]], elide: Bool) -> [[Syllable]] {
        // Perform long-by-position across words
        let result = syllables.reduce(into: [[Syllable]]()) {
            if let last = $0.last?.last, !(last.isLong ?? false) {
                // If we have a case of '-c c-', then the former syllable becomes long by position
                if last.value.last.map({ Syllabifier.isConsonant($0) }) ?? false,
                   $1.first.map({ Syllabifier.startsWithScanConsonant($0.value) }) ?? false {
                    $0[$0.count - 1][$0.last!.count - 1].isLong = true
                }
                // Likewise, a case of '-v cc-', produces a similar result
                else if $1.first?.value.first.map({ Syllabifier.isConsonant($0) }) ?? false,
                        let droppedFront = $1.first?.value.dropFirst(),
                        Syllabifier.startsWithScanConsonant(String(droppedFront)) {
                    let isLiquidFlexible = $1.first?.value.first != droppedFront.first && Syllabifier.isLiquid(droppedFront.first ?? " ")
                    $0[$0.count - 1][$0.last!.count - 1].isLong = isLiquidFlexible ? nil : true
                }
            }
            $0.append($1)
        }
        // Perform elisions:
        // - Vowel elision
        // - 'H' elision (MAYBE?)
        // - '-m' nasalization elision
        return elide ? result.reduce(into: [[Syllable]]()) {
            let performElision = { (r: inout [[Syllable]], w: [Syllable]) in
                r[r.count - 1][r.last!.count - 1].value += "_\(w.first!.value)"
                r[r.count - 1][r.last!.count - 1].isLong = w.first!.isLong
                r[r.count - 1] += w[1...]
            }
            
            // In the scenario of '-v1 v2-', the v1 gets knocked out and the syllable merges with the v2 one: '-v2-'
            if let last = $0.last?.last, Syllabifier.isOpen((last.value, false /* dummy value */)),
               let first = $1.first?.value, Syllabifier.startsWithVowel(first) {
                performElision(&$0, $1)
            }
            // In the scenario of '-v1m v2-', the v1m gets knocked out and the syllable merges with the v2 one: '-v2-'
            else if let last = $0.last?.last?.value,
               last.dropLast().last.map({ Syllabifier.isVowel($0) }) ?? false,
               last.last == "m" || last.last == "M",
               let first = $1.first?.value, Syllabifier.startsWithVowel(first) {
                performElision(&$0, $1)
            }
            // If none of these elision attempts suceeded, simply append the syllables as is
            else {
                $0.append($1)
            }
        } : result
    }
    
    /// Represents
    public enum Meter {
        /// Dactylic hexameter. This constitutes a mixture of dactyls and spondees within the first five feet, with a final spondee.
        ///
        /// - Warning: This will fail to match lines such as Aen X.X with a single long as the final foot.
        case hexameter
    }
    
    public static func match(line: [String], against meter: Meter) -> Bool {
        // Convert words to syllables
        return match(line: Scanner.scan(line: line, elide: true), against: meter)
    }
    
    public static func match(line: [[Syllable]], against meter: Meter) -> Bool {
        func applyingTemplates(_ templates: [[Bool?]], to syllables: [Syllable]) -> [Syllable]? {
            for template in templates {
                var matched = true
                // Applies the template from reverse
                for (actual, test) in zip(syllables.reversed(), template.reversed()) {
                    if actual.isLong != test {
                        matched = false
                    }
                }
                // Upon a match, drop those last items
                if matched {
                    return Array(syllables.dropLast(template.count))
                }
            }
            return nil
        }
        
        // Templates
        let combined = line.reduce([]) { $0 + $1 }
        let dactyl = [
            [true, false, false], [true, nil, false], [true, false, nil], [nil, false, false]
        ]
        let spondee = [
            [true, true], [true, nil], [nil, true]
        ]
        let finalSpondee = spondee + [
            [true, false], [nil, false] // brevis in longō
        ]
        
        switch meter {
        case .hexameter:
            var result = applyingTemplates(finalSpondee, to: combined)
            for _ in 0 ..< 5 {
                guard let unwrapped = result, !unwrapped.isEmpty else {
                    return false
                }
                result = applyingTemplates(dactyl, to: unwrapped)
                if result == nil {
                    result = applyingTemplates(spondee, to: unwrapped)
                }
            }
            return result?.isEmpty ?? false
        default:
            return false
        }
        
    }
}
