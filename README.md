# scanner
A tool for the syllabification of Latin words and scanning of verse lines

```
Arma virumque canō Trōiae quī prīmus ab ōrīs
- u  u -  u   u -  -  -   -   -  u   u  --   
The line is ✅ valid hexameter

Ītaliam fātō profugus Lāviniaque vēnit
-u u -  - -  u  u -   - u u uu   - u   
The line is ❌ invalid hexameter

Ītaliam fātō profugus Lāvinjaque vēnit
-u u -  - -  u  u -   - -  u u   - u   
The line is ✅ valid hexameter

lītora multum_ille_et terrīs iactātus et altō
- u u  -  -     -     -  -   -  - u   u  - -  
The line is ✅ valid hexameter

vī superum saevae memorem Iūnōnis ob īram
-  u u -   -  -   u u -   - - u   u  -u   
The line is ✅ valid hexameter
```

## The Syllabifier

The syllabifier (see [source file](/src/syllabifier.swift)) takes a Latin word as input and produces its syllable composition. It does so by following the main rules of Latin syllabification, those being:
1. Every syllable contains a single vowel or a diphthong
2. Consonants prefer to start a syllable
3. Multiple consonants will leave the final consonant for the following syllable
4. Double consonants are broken up

As an example, here is the word _obiectum_ syllabified (the [supine](https://dcc.dickinson.edu/grammar/latin/supine) in "-um" of the verb [_obiciō_](https://en.wiktionary.org/wiki/obicio#Latin)):

```
ob.iec.tum
-  -   u
```

In this example, a few of the rules above are applied:
- Each syllable has a vowel (rule 1)
- Rule 3 is applied to the `b` and consonantal `i` (_o**b.i**ectum_)
- Rule 3 is once again applied to the `c` and `t` (_ie**c.t**um_)

Both cases where rule 3 was applied are marked long (`-`) by position. The final syllable is marked short (`u`) because there is a single consonant ending the syllable and the vowel is short.

The syllabifier can usually infer consonantal `i` (shown in this example), so `j` is often not necessary.

### Limitations

- Macrons must be provided for correct syllable length
- No attempt is made to derive consonantal `u`: `v` is required in order to syllabify properly

## The Scanner

The scanner (see [source file](/src/scanner.swift)) takes a series of Latin words as input and provides the modified long and short qualities, using some Latin verse rules:
1. Long by position works across word boundaries
2. Open syllables (syllables ending with a vowel) elide with those starting with a vowel
3. A final -um is nasalized and elides with syllables starting with a vowel

This list of rules is not the complete set, but it is all the scanner currently supports. Further iterations will include h-elision among other things.

Example:
```
Arma virumque canō Trōiae quī prīmus ab ōrīs
- u  u -  u   u -  -  -   -   -  u   u  --   
```

### Verse Verification

The scanner can determine whether a given line of verse falls under a certain meter (as of now, the only meter supported is dactylic hexameter, denoted by `Scanner.Meter.hexameter`). It does this by reverse template matching (reading from right to left) the metrical feet allowed onto the words.

Example:
```
Arma virumque canō Trōiae quī prīmus ab ōrīs
- u  u -  u   u -  -  -   -   -  u   u  --   
The line is ✅ valid hexameter
```
