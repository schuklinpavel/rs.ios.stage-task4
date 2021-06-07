import Foundation

public extension Int {
    
    var roman: String? {
        guard self > 0, self < 4000 else {
            return nil
        }
        
        var num = self
        
        let map = [
            "M": 1000,
            "CM": 900,
            "D": 500,
            "CD": 400,
            "C": 100,
            "XC": 90,
            "L": 50,
            "XL": 40,
            "X": 10,
            "IX": 9,
            "V": 5,
            "IV": 4,
            "I": 1,
        ]
        
        var result = ""
        
        for key in map.sorted(by: {$0.1 > $1.1}) {
            let repeatCounter = floor(Double(num / key.1))
            
            if (repeatCounter != 0) {
                result += String(repeating: key.0, count: Int(repeatCounter))
            }
            
            num %= key.1
            
            if (num == 0) {
                return result
            }
        }
        
        return result
    }
}
