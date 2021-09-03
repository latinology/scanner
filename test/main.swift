// scanner: main.swift: A sample program testing the functionality of the syllabifier and scanner.
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

SyllabifierTests.test {
    $0("amīcus", ["a", "mī", "cus"], [.endingConsonant])
    $0("traxit", ["trac", "sit"], [.doubleConsonants, .endingConsonant])
    $0("princeps", ["prin", "ceps"], [.consecConsonants, .endingConsonant])
    $0("formārum", ["for", "mā", "rum"], [.consecConsonants, .endingConsonant])
    $0("autoraeda", ["au", "to", "rae", "da"], [.diphthongs, .endingVowel])
    $0("interrete", ["in", "ter", "re", "te"], [.consecConsonants, .endingVowel])
    $0("dormiebam", ["dor", "mi", "e", "bam"], [.consecConsonants, .fauxConsonantalI, .endingConsonant])
    $0("arbōris", ["ar", "bō", "ris"], [.consecConsonants, .endingConsonant])
    $0("mercātōribus", ["mer", "cā", "tō", "ri", "bus"], [.consecConsonants, .endingConsonant])
    $0("praestāvistī", ["praes", "tā", "vis", "tī"], [.consecConsonants, .diphthongs, .endingVowel])
    $0("subiectum", ["sub", "iec", "tum"], [.consecConsonants, .consonantalI, .endingConsonant])
    $0("quaestiō", ["quaes", "ti", "ō"], [.consecConsonants, .fauxConsonantalI, .endingVowel, .quCombs])
    $0("quārum", ["quā", "rum"], [.endingConsonant, .quCombs])
    $0("obiectum", ["ob", "iec", "tum"], [.consecConsonants, .consonantalI, .endingConsonant])
    $0("frigidō", ["fri", "gi", "dō"], [.consecConsonants, .endingVowel])
    $0("trānsportātiōnēs", ["trāns", "por", "tā", "ti", "ō", "nēs"], [.consecConsonants, .consecVowels, .fauxConsonantalI, .endingConsonant])
    $0("ūnius", ["ū", "ni", "us"], [.consecVowels, .fauxConsonantalI, .endingConsonant])
    $0("arma", ["ar", "ma"], [.consecConsonants, .endingVowel])
    $0("virumque", ["vi", "rum", "que"], [.consecConsonants, .endingVowel, .quCombs])
    $0("canō", ["ca", "nō"], [.endingVowel])
    $0("Trōiae", ["Trō", "iae"], [.diphthongs, .consonantalI, .endingVowel])
    $0("iō", ["iō"], [.consonantalI, .endingVowel])
    $0("Saturnālia", ["Sa", "tur", "nā", "li", "a"], [.consecConsonants, .fauxConsonantalI, .endingVowel])
    $0("Caecilius", ["Cae", "ci", "li", "us"], [.diphthongs, .fauxConsonantalI, .endingConsonant])
    $0("Commentāriī", ["Com", "men", "tā", "ri", "ī"], [.consecConsonants, .fauxConsonantalI, .endingVowel])
    $0("dē", ["dē"], [.endingVowel])
    $0("Bellō", ["Bel", "lō"], [.consecConsonants, .endingVowel])
    $0("Gallicō", ["Gal", "li", "cō"], [.consecConsonants, .endingVowel])
}//() // uncomment the `()` to run syllabifier tests

// Scan the first few lines of the Aeneid
ScannerTests.dumpScan(line: "Arma virumque canō, Trōiae quī prīmus ab ōrīs")
ScannerTests.dumpScan(line: "Ītaliam fātō profugus Lāviniaque vēnit") // will not work (yet)
ScannerTests.dumpScan(line: "Ītaliam fātō profugus Lāvinjaque vēnit")
ScannerTests.dumpScan(line: "lītora, multum ille et terrīs iactātus et altō,")
ScannerTests.dumpScan(line: "vī superum, saevae memorem Iūnōnis ob īram")
ScannerTests.dumpScan(line: "multa quoque et bellō passus dūm cōnderet urbem")
ScannerTests.dumpScan(line: "inferretque deōs Latiōs genus unde Latīnum,")
ScannerTests.dumpScan(line: "Albānīque patrēs atque altae moenia Rōmae")
