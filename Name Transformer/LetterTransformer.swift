import Foundation

struct LetterTransformer {
    static let similarLetters: [Character: [[Character]]] = [
        // Uppercase letters
        "A": [["Α", "Ą", "Ⱥ"], ["А", "Ā", "Ă"]],
        "B": [["Β", "Ḃ", "Ḅ"], ["В", "Ɓ", "Ḇ"]],
        "C": [["Ϲ", "Ċ", "Ḉ"], ["С", "Ç", "Ć"]],
        "D": [["Ď", "Ḋ", "Ḍ"], ["Ð", "Đ", "Ɗ"]],
        "E": [["Ε", "Ę", "Ḗ"], ["Е", "Ē", "Ė"]],
        "F": [["Ϝ", "Ƒ", "Ḟ"], ["Ф", "Ḟ", "Ƒ"]],
        "G": [["Ģ", "Ǥ", "Ḡ"], ["Ğ", "Ġ", "Ǧ"]],
        "H": [["Η", "Ħ", "Ḣ"], ["Н", "Ĥ", "Ḥ"]],
        "I": [["Ι", "Į", "Ḭ"], ["І", "Ī", "Ĭ"]],
        "J": [["Ј", "Ĵ", "Ɉ"], ["Ј", "Ɉ", "Ĵ"]],
        "K": [["Κ", "Ķ", "Ḳ"], ["К", "Ǩ", "Ḵ"]],
        "L": [["Ļ", "Ḷ", "Ḻ"], ["Ł", "Ĺ", "Ḽ"]],
        "M": [["Μ", "Ṁ", "Ṃ"], ["М", "Ḿ", "Ṁ"]],
        "N": [["Ν", "Ņ", "Ṅ"], ["Н", "Ń", "Ň"]],
        "O": [["Ο", "Ǫ", "Ȯ"], ["О", "Ō", "Ő"]],
        "P": [["Ρ", "Ṗ", "Ṕ"], ["Р", "Ƥ", "Ṗ"]],
        "Q": [["Ԛ", "Ɋ", "Ǫ"], ["Ԛ", "Ɋ", "Q"]],
        "R": [["Ŕ", "Ṙ", "Ṛ"], ["Ř", "Ŗ", "Ṝ"]],
        "S": [["Ѕ", "Ṡ", "Ṣ"], ["Ś", "Ŝ", "Ș"]],
        "T": [["Τ", "Ṫ", "Ṭ"], ["Т", "Ť", "Ț"]],
        "U": [["Υ", "Ų", "Ṳ"], ["У", "Ū", "Ů"]],
        "V": [["Ѵ", "Ṿ", "Ѷ"], ["В", "Ѵ", "Ṽ"]],
        "W": [["Ԝ", "Ẃ", "Ẅ"], ["Ŵ", "Ẁ", "Ẇ"]],
        "X": [["Χ", "Ẋ", "Ẍ"], ["Х", "Ẋ", "Ẍ"]],
        "Y": [["Υ", "Ẏ", "Ỵ"], ["У", "Ŷ", "Ỹ"]],
        "Z": [["Ζ", "Ż", "Ẓ"], ["З", "Ź", "Ž"]],
        
        // Lowercase letters
        "a": [["α", "ą", "ⱥ"], ["а", "ā", "ă"]],
        "b": [["β", "ḃ", "ḅ"], ["в", "ɓ", "ḇ"]],
        "c": [["ϲ", "ċ", "ḉ"], ["с", "ç", "ć"]],
        "d": [["ď", "ḋ", "ḍ"], ["ð", "đ", "ɗ"]],
        "e": [["ε", "ę", "ḗ"], ["е", "ē", "ė"]],
        "f": [["ϝ", "ƒ", "ḟ"], ["ф", "ḟ", "ƒ"]],
        "g": [["ģ", "ǥ", "ḡ"], ["ğ", "ġ", "ǧ"]],
        "h": [["η", "ħ", "ḣ"], ["н", "ĥ", "ḥ"]],
        "i": [["ι", "į", "ḭ"], ["і", "ī", "ĭ"]],
        "j": [["ј", "ĵ", "ɉ"], ["ј", "ɉ", "ĵ"]],
        "k": [["κ", "ķ", "ḳ"], ["к", "ǩ", "ḵ"]],
        "l": [["ļ", "ḷ", "ḻ"], ["ł", "ĺ", "ḽ"]],
        "m": [["μ", "ṁ", "ṃ"], ["м", "ḿ", "ṁ"]],
        "n": [["ν", "ņ", "ṅ"], ["н", "ń", "ň"]],
        "o": [["ο", "ǫ", "ȯ"], ["о", "ō", "ő"]],
        "p": [["ρ", "ṗ", "ṕ"], ["р", "ƥ", "ṗ"]],
        "q": [["ԛ", "ɋ", "ǫ"], ["ԛ", "ɋ", "q"]],
        "r": [["ŕ", "ṙ", "ṛ"], ["ř", "ŗ", "ṝ"]],
        "s": [["ѕ", "ṡ", "ṣ"], ["ś", "ŝ", "ș"]],
        "t": [["τ", "ṫ", "ṭ"], ["т", "ť", "ț"]],
        "u": [["υ", "ų", "ṳ"], ["у", "ū", "ů"]],
        "v": [["ѵ", "ṿ", "ѷ"], ["в", "ѵ", "ṽ"]],
        "w": [["ω", "ẃ", "ẅ"], ["ŵ", "ẁ", "ẇ"]],
        "x": [["χ", "ẋ", "ẍ"], ["х", "ẋ", "ẍ"]],
        "y": [["у", "ẏ", "ỵ"], ["у", "ŷ", "ỹ"]],
        "z": [["ζ", "ż", "ẓ"], ["з", "ź", "ž"]],
        
        // Numbers
        "0": [["⓪", "⓿", "𝟎"], ["𝟢", "𝟬", "𝟶"]],
        "1": [["①", "⓵", "𝟏"], ["𝟣", "𝟭", "𝟷"]],
        "2": [["②", "⓶", "𝟐"], ["𝟤", "𝟮", "𝟸"]],
        "3": [["③", "⓷", "𝟑"], ["𝟥", "𝟯", "𝟹"]],
        "4": [["④", "⓸", "𝟒"], ["𝟦", "𝟰", "𝟺"]],
        "5": [["⑤", "⓹", "𝟓"], ["𝟧", "𝟱", "𝟻"]],
        "6": [["⑥", "⓺", "𝟔"], ["𝟨", "𝟲", "𝟼"]],
        "7": [["⑦", "⓻", "𝟕"], ["𝟩", "𝟳", "𝟽"]],
        "8": [["⑧", "⓼", "𝟖"], ["𝟪", "𝟴", "𝟾"]],
        "9": [["⑨", "⓽", "𝟗"], ["𝟫", "𝟵", "𝟿"]],
        
        // Special Characters
        ".": [["․", "。", "｡"], ["．", "·", "∙"]],
        ",": [["،", "、", "︐"], ["，", "፣", "⸲"]],
        "!": [["ǃ", "❗", "ꜝ"], ["！", "‼", "❣"]],
        "?": [["❓", "？", "؟"], ["⁇", "❔", "꘏"]],
        "@": [["＠", "⒜", "ⓐ"], ["@", "﹫", "☯"]],
        "#": [["＃", "♯", "⌗"], ["#", "⋕", "⨳"]],
        "$": [["＄", "₮", "₯"], ["$", "₫", "₴"]],
        "%": [["％", "⁒", "٪"], ["%", "⌘", "⌗"]],
        "&": [["＆", "﹠", "＆"], ["&", "⅋", "℆"]],
        "*": [["＊", "⋆", "✱"], ["*", "✲", "✳"]]
    ]
    
    static func transform(_ input: String, index: Int) -> String {
        return String(input.map { char in
            if let alternatives = similarLetters[char] {
                let variantSet = alternatives[index % alternatives.count]
                return variantSet[Int.random(in: 0..<variantSet.count)]
            }
            return char
        })
    }
} 