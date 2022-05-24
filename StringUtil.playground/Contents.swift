// Copyright 2017 Mike Retondo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//: Playground - noun: a place where people can play

import Swift
import Foundation

public extension StringProtocol {

    // [i]
    subscript(i: Int) -> Character {
        return self[index(at: i)]
    }

    // [i..<j]
    subscript(range: Range<Int>) -> SubSequence {
        let i = index(at: range.lowerBound)
        let j = index(at: range.upperBound)
        return self[i..<j]
    }

    // [i...j]
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let i = index(at: range.lowerBound)
        let j = index(at: range.upperBound)
        return self[i...j]
    }

    // [..<i]
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence {
        let i = index(at: range.upperBound)
        return self[..<i]
    }

    // [...i]
    subscript(range: PartialRangeThrough<Int>) -> SubSequence {
        let i = index(at: range.upperBound)
        return self[...i]
    }

    // [i...]
    subscript(range: PartialRangeFrom<Int>) -> SubSequence {
        let i = index(at: range.lowerBound)
        return self[i...]
    }
}

public extension StringProtocol {

    /// Returns an array of indices where 'string' is located with in the string.
    ///
    /// - Parameters:
    ///   - string: The string to search for.
    /// - Returns: An array of String.Index.
    func indices(of string: String) -> [Index] {
        var indices = [Index]()
        var start = self.startIndex
        while start < self.endIndex, let range = range(of: string, range: start..<self.endIndex), !range.isEmpty {
            //            let IndexDistance: String.IndexDistance = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(range.lowerBound)
            start = range.upperBound
        }
        return indices
    }

    /// Returns an index that is the specified distance from the start or end of the
    /// string. If 'n' is positive then offset start from the beginning of the string
    /// else from the end of the string.
    ///
    /// The value passed as `n` must not offset beyond the bounds of the collection.
    ///
    /// - Parameters:
    ///   - n: The distance to offset.
    /// - Returns: An index offset by `n`. If `n` is positive, this is the same value
    ///   as the result of `n` calls to `index(after:)`.
    ///   If `n` is negative, this is the same value as the result of `-n` calls
    ///   to `index(before:)`.
    func index(at n: String.IndexDistance) -> Index {
        if n == 0 {
            return self.startIndex
        } else if n >= 0 {
            return index(self.startIndex, offsetBy: n)
        } else {
            return index(self.endIndex, offsetBy: n)
        }
    }

    @inline(__always)
    func indexRangeFor(range: Range<Int>) -> Range<Index> {
        return index(at: range.lowerBound)..<index(at: range.upperBound)
    }

    @inline(__always)
    func indexRangeFor(range: ClosedRange<Int>) -> ClosedRange<Index> {
        return index(at: range.lowerBound)...index(at: range.upperBound)
    }
}

public extension StringProtocol {

    /// Returns a subsequence, containing the Range<Int> within.
    ///
    /// - Parameters:
    ///   - range: A half-open interval from a lower bound up to, but not including, an upper bound.
    func substring(with range: Range<Int>) -> SubSequence? {
        let r = 0...count

        guard r.contains(range.lowerBound) && r.contains(range.upperBound) else { return nil }

        let start = index(at: range.lowerBound)
        let end = index(at: range.upperBound)

        return self[start..<end]
    }

    /// Returns a subsequence, containing the ClosedRange<Int> within.
    ///
    /// - Parameters:
    ///   - range: A ClosedRange interval from a lower bound up to, but not including, an upper bound.
    func substring(with range: ClosedRange<Int>) -> SubSequence? {
        let r = 0..<count

        guard r.contains(range.lowerBound) && r.contains(range.upperBound) else { return nil }

        let start = index(at: range.lowerBound)
        let end = index(at: range.upperBound)

        return self[start...end]
    }

    /// 'i' can be negitive to go in reverse direction
    func substring(from i: Int) -> SubSequence? {
        guard abs(i) < count else { return nil }

        let fromIndex = i >= 0 ? index(at: i) : index(self.endIndex, offsetBy: i)
        let toIndex   = i >= 0 ? self.endIndex : self.startIndex

        return i >= 0 ? self[fromIndex..<toIndex] : self[toIndex..<fromIndex]
    }

    /// 'i' can be negitive to go in reverse direction
    func substring(to i: Int) -> SubSequence? {
        guard abs(i) <= count else { return nil }

        let fromIndex = i >= 0 ? self.startIndex : self.endIndex
        let toIndex   = i >= 0 ? index(at: i) : index(self.endIndex, offsetBy: i)

        return i >= 0 ? self[fromIndex..<toIndex] : self[toIndex..<fromIndex]
    }
}

public extension StringProtocol {
    //
    // infix is to complement prefix and suffix
    //

    /// Companion function to String.prefix() and String.suffix(). It is similar to
    /// Basic's Mid() fuction.
    ///
    /// Returns a subsequence, starting from position up to the specified
    /// maximum length, containing the middle elements of the collection.
    ///
    /// If the maximum length exceeds the remaing number of elements in the
    /// collection, the result contains all the remaining elements in the collection.
    ///
    ///     let numbers = [1, 2, 3, 4, 5]
    ///     print(numbers.infix(from: 2, maxLength: 2))
    ///     // Prints "[3, 4]"
    ///     print(numbers.prefix(from: 2, maxLength: 10))
    ///     // Prints "[3, 4, 5]"
    ///     print(numbers.prefix(from: 10, maxLength: 2))
    ///     // Prints ""
    ///     print(numbers.infix(from: 0))
    ///     // Prints "[1, 2, 3, 4, 5]"
    ///     print(numbers.infix(from: 2))
    ///     // Prints "[3, 4, 5]"
    ///     print(numbers.infix(from: 10))
    ///     // Prints ""
    ///
    /// - Parameters:
    ///   - position: The starting element (charecter) position in the collection. `position` must be
    ///     greater than or equal to zero.
    ///   - maxLength: The maximum number of elements to return. `maxLength`
    ///     must be greater than zero. The default for `maxLength` is set so
    ///     is set so the remaining elements of the collection will be returned.
    /// - Returns: A subsequence starting from `position` up to `maxLength`
    ///   elements in the collection.
    func infix(from position: Int, maxLength: Int = Int.max) -> SubSequence {
        // if 'position' is beyond the last charecter position then set 'start' to 'endIndex'
        let start = index(startIndex, offsetBy: numericCast(position), limitedBy: endIndex) ?? endIndex

        // if 'start' + 'maxLength' is beyond the last charecter position then set end to 'endIndex'
        let end = index(start, offsetBy: numericCast(maxLength), limitedBy: endIndex) ?? endIndex

        return self[start..<end]
    }

    /// Returns a subsequence, starting from position and containing the elements
    /// until `predicate` returns `false` and skipping the remaining elements.
    ///
    /// - Parameters:
    ///   - position: The starting element (charecter) position in the collection. `position` must be
    ///     greater than or equal to zero.
    ///   - predicate: A closure that takes an element of the sequence as its
    ///     argument and returns `true` if the element should be included or
    ///     `false` if it should be excluded. Once the predicate
    ///   returns `false` it will not be called again.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    func infix(from position: Int, while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
        // if 'position' is beyond the last charecter position then set 'start' to 'endIndex'
        let start = index(startIndex, offsetBy: numericCast(position), limitedBy: endIndex) ?? endIndex

        var end = start
        while try end != endIndex && predicate(self[end]) {
            formIndex(after: &end)
        }

        return self[start..<end]
    }

    @inline(__always)
    func infix(from start: String.Index, upTo end: String.Index) -> SubSequence {
        return self[start..<end]
    }

    @inline(__always)
    func infix(from start: String.Index, through end: String.Index) -> SubSequence {
        return self[start...end]
    }
}

extension StringProtocol {

    /// Returns the index? starting where the subString was found.
    ///
    ///    let str = "abcde"
    ///    if let index = str.index(of: "cd") {
    ///        let substring = str[..<index]   // ab
    ///        let string = String(substring)
    ///        print(string)  // "ab\n"
    ///    }
    ///
    ///    let str = "Hello, playground, playground, playground"
    ///    str.index(of: "play")      // 7
    ///    str.endIndex(of: "play")   // 11
    ///    str.indices(of: "play")    // [7, 19, 31]
    ///    str.ranges(of: "play")     // [{lowerBound 7, upperBound 11}, {lowerBound 19, upperBound 23}, {lowerBound 31, upperBound 35}]
    ///
    /// - Parameters:
    ///   - string: subString to find.
    ///   - options: Default [], String.CompareOptions,
    ///     values that represent the options available to search and comparison.
    /// - Returns: index where string starts
    func index<T: StringProtocol>(of string: T, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }

    /// Returns the index? after where the subString was found.
    ///
    ///    let str = "abcde"
    ///    if let index = str.index(of: "cd") {
    ///        let substring = str[..<index]   // ab
    ///        let string = String(substring)
    ///        print(string)  // "ab\n"
    ///    }
    ///
    ///    let str = "Hello, playground, playground, playground"
    ///    str.endIndex(of: "play")   // 11
    ///
    /// - Parameters:
    ///   - string: subString to find.
    ///   - options: Default [], String.CompareOptions,
    ///     values that represent the options available to search and comparison.
    /// - Returns: index where string ends
    func endIndex<T: StringProtocol>(of string: T, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }

    /// Return indeces of all the locations where the subString was found.
    ///
    ///    let str = "abcde"
    ///    if let index = str.index(of: "cd") {
    ///        let substring = str[..<index]   // ab
    ///        let string = String(substring)
    ///        print(string)  // "ab\n"
    ///    }
    ///
    ///    let str = "Hello, playground, playground, playground"
    ///    str.indices(of: "play")    // [7, 19, 31]
    ///
    /// - Parameters:
    ///   - string: subString to find.
    ///   - options: Default [], String.CompareOptions,
    ///     values that represent the options available to search and comparison.
    /// - Returns: [String.Index] where string was found
    func indices<T: StringProtocol>(of string: T, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex

        while startIndex < endIndex, let range = self[startIndex...].range(of: string, options: options) {
            indices.append(range.lowerBound)
            startIndex = range.lowerBound < range.upperBound ?
                range.upperBound :
                index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }

        return indices
    }

    /// Return ranges of all the locations where the subString was found.
    ///
    ///    let str = "Hello, playground, playground, playground"
    ///    str.ranges(of: "play")     // [{lowerBound 7, upperBound 11}, {lowerBound 19, upperBound 23}, {lowerBound 31, upperBound 35}]
    ///
    ///    case insensitive sample:
    ///
    ///    let query = "Play"
    ///    let ranges = str.ranges(of: query, options: .caseInsensitive)
    ///    let matches = ranges.map { str[$0] }
    ///    print(matches)  // ["play", "play", "play"]
    ///
    ///    regular expression sample:
    ///
    ///    let query = "play"
    ///    let escapedQuery = NSRegularExpression.escapedPattern(for: query)
    ///    let pattern = "\\b\(escapedQuery)\\w+"  // matches any word that starts with "play" prefix
    ///    let ranges = str.ranges(of: pattern, options: .regularExpression)
    ///    let matches = ranges.map { str[$0] }
    ///    print(matches) //  ["playground", "playground", "playground"]
    ///
    /// - Parameters:
    ///   - string: subString to find.
    ///   - options: Default [], String.CompareOptions,
    ///     values that represent the options available to search and comparison.
    /// - Returns: [Range<Index>] where string was found
    func ranges<T: StringProtocol>(of string: T, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex

        while startIndex < endIndex, let range = self[startIndex...].range(of: string, options: options) {
            result.append(range)
            startIndex = range.lowerBound < range.upperBound ?
                range.upperBound :
                index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }

        return result
    }
}

public extension String {

    /// Returns the number of bytes used to hold the string. This works because
    /// Swift 5 now uses UTF-8 as it's backing store.
    @inline(__always)
    var size: Int {
        // utf8 will treat \r\n as 2 character so "\r\n".utf8.count returns 2
        // Unicode treats \r\n as 1 character so "\r\n".count returns 1
        get {utf8.count}
    }
}

public extension String {

    /// returns a Strings length as a NSString length
    @inline(__always)
    var length: Int {
        // NSString length is equal to the number of UTF-16 code units
        get { return (self as NSString).length }
    }
}

public extension String {

    /// returns true if string contains any non ascii characters else false
    @inline(__always)
    var isAscii: Bool {
        get {
            return self == "" || lengthOfBytes(using: .ascii) != 0
        }
    }
}


public extension String {

    /// Returns a new string with repeating current string 'count' times
    func repeated(count: Int) -> String {
        return [String].init(repeating: self, count: count).joined()
    }

    /// Returns a new string by replacing matches of pattern with replacement.
    func replacedMatches(of pattern: String, with replacement: String) -> String {
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSMakeRange(0, utf16.count)

        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacement)
    }

    /// Returns a new string in which all occurrences of a target string
    /// in a specified range of the string are removed.
    func removedOccurrences(of occurrence: String, options: String.CompareOptions = []) -> String {
        return replacingOccurrences(of: occurrence, with: "", options: options)
    }
}

public extension String {

    /// Returns a new string made by removing all whitespacesAndNewlines.
    func trimmingWhitepaceAndNewlines() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Returns a new string made by removing all leading whitespacesAndNewlines.
    func trimmingLeadingWhitepaceAndNewlines() -> String {
        let newString = self

        if let range = rangeOfCharacter(from: .whitespacesAndNewlines, options: [.anchored,]) {
            return String(newString[range.upperBound...]).trimmingLeadingWhitepaceAndNewlines()
        }
        return newString
    }

    /// Returns a new string made by removing all trailing whitespacesAndNewlines.
    func trimmingTrailingWhitepaceAndNewlines() -> String {
        let newString = self

        if let range = rangeOfCharacter(from: .whitespacesAndNewlines, options: [.anchored, .backwards]) {
            return String(newString[..<range.lowerBound]).trimmingTrailingWhitepaceAndNewlines()
        }
        return newString
    }
}

public extension String {

    /// Replaces the text within the specified bounds starting at 'position'
    /// and a length of 'maxLength with the given characters.
    /// Calling this method invalidates any existing indices for use with this string.
    ///
    /// - Parameters:
    ///   - position: The starting charecter position in the collection. `position` must be
    ///     greater than or equal to zero.
    ///   - maxLength: The maximum number of elements to modifiy. `maxLength`
    ///     must be greater than or equal to zero.
    ///   - newString: The new newString to add to the string.
    mutating func replace(from position: Int, maxLength: Int, with newString: String) {
        // if 'position' is beyond the end then set 'start' to 'endIndex'
        let start = index(startIndex, offsetBy: numericCast(position), limitedBy: endIndex) ?? endIndex

        // if 'start' + 'maxLength' is beyond the end then set end to 'endIndex'
        let end = index(start, offsetBy: numericCast(maxLength), limitedBy: endIndex) ?? endIndex

        replaceSubrange(start..<end, with: newString)
    }

    /// Removes the text within the specified bounds starting at 'position'
    /// and a length of 'maxLength.
    ///
    /// Calling this method invalidates any existing indices for use with this string.
    ///
    /// - Parameters:
    ///   - position: The starting charecter position in the collection. `position` must be
    ///     greater than or equal to zero.
    ///   - maxLength: The maximum number of elements to return. `maxLength`
    ///     must be greater than or equal to zero. If `maxLength` is not used
    ///     then `maxLength` is set to the remaining elements from `start`.
    mutating func remove(from position: Int, maxLength: Int = Int.max) {
        // if 'position' is beyond the end then set 'start' to 'endIndex'
        let start = index(startIndex, offsetBy: numericCast(position), limitedBy: endIndex) ?? endIndex

        // if 'start' + 'maxLength' is beyond the end then set end to 'endIndex'
        let end = index(start, offsetBy: numericCast(maxLength), limitedBy: endIndex) ?? endIndex

        removeSubrange(start..<end)
    }
}

public extension String {

    func lineOneSpaceAt(pin: Int) -> (Int, String) {

        var start = pin
        while start > 0 && self[start - 1] == " " {
            start -= 1
        }

        var end = pin
        while end < count && self[end] == " " {
            end += 1
        }

        var newString = self
        if start == end {//No space
            newString.replaceSubrange(index(at: start)..<index(at: start), with: " ")
        } else if end - start == 1 {//If one space
            let range = index(at: start)..<index(at: end)
            newString.replaceSubrange(range, with: " ")
        } else { //More than one space
            let range = index(at: start)..<index(at: end)
            newString.replaceSubrange(range, with: " ")
        }
        return (start, newString)
    }

    func selectWord(pin: Int) -> Range<String.Index>? {
        guard let range:Range<Int> = selectWord(pin: pin) else { return nil }
        return indexRangeFor(range: range)
    }

    func selectWord(pin: Int) -> Range<Int>? {
        var pin = pin

        guard pin <= count else { return nil }
        guard count > 1  else { return nil }

        // Move pin to one position left when it is after last character
        let invalidLastChars = CharacterSet(charactersIn: " :!?,.")
        var validChars = CharacterSet.alphanumerics
        validChars.insert(charactersIn: "@_")

        if (pin > 0), let _ = (String(self[pin])).rangeOfCharacter(from: invalidLastChars) {
            if let _ = (String(self[pin - 1])).rangeOfCharacter(from: validChars) {
                pin -= 1
            }
        }

        var start = pin
        while start >= 0 && (String(self[start])).rangeOfCharacter(from: validChars) != nil {
            start -= 1
        }

        var end = pin
        while end < count && (String(self[end])).rangeOfCharacter(from: validChars) != nil {
            end += 1
        }
        if start == end { return nil }
        return start + 1..<end
    }

    /// All multiple whitespaces are replaced by one whitespace
    var condensedWhitespace: String {
        let components = self.components(separatedBy: .whitespaces)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}


var str2 = "🇩🇪👨‍👩‍👧‍👦👩‍❤️‍👩🇺🇸🇫🇷🇮🇹🇬🇧🇪🇸🇯🇵🇷🇺🇨🇳"
var c = str2[2]
print(type(of: c))
var d = str2[str2.startIndex]
print(type(of: d))
str2[1] == "👨‍👩‍👧‍👦"
str2[...4]
str2[..<4]
str2[1...4]
str2[1..<4]
str2[6...]
str2[6..<8]

var houses = "🏠🏡🏠🏡🏠"
houses.replace(from: 3, maxLength: 1, with: "🐴")
houses = "🏠🏡🏠🏡🏠"
houses.replace(from: 3, maxLength: 1, with: "🐴A")
houses = "\u{00E9}Aﬃ🏡🏠"
houses.replace(from: 2, maxLength: 2, with: "e")
houses = "🏠🏡🏠🏡🏠"
houses.replace(from: 2, maxLength: 1, with: "ﬃ🐴A")


// String experiments
let hello = "hello"
let startIndex = hello.startIndex // 0
let endIndex = hello.endIndex     // 5
hello[startIndex]                 // "h"
let x = hello[hello.index(before: endIndex)]                 // "h"

let ss = "Hello, Swift"
ss[ss.startIndex..<ss.endIndex]

let earth = "🌍"

let multipleFlags: Character = "🇩🇪🇺🇸🇫🇷🇮🇹🇬🇧🇪🇸🇯🇵🇷🇺🇨🇳" // DE US FR IT GB ES JP RU CN
print (multipleFlags) // single character YEP! single character
var multipleFlagsString = String(multipleFlags) + "!"
multipleFlagsString.count // 10 user perceived characters
print (multipleFlagsString) // string of 10 charaters


var ligature = "ﬃ"
ligature.count // -> 1 user perceived character
ligature += " ffi" // append non ligature
ligature.count // -> 1 user perceived character
// get the EXACT number of bytes needed to store the String
var numberOfBytes = ligature.lengthOfBytes(using: .utf32)
// Get an ESTIMATE of the maximum number of bytes needed to store the String
// May be considerably greater than the actual length needed, faster than lengthOfBytes(using:)
var maxNumberOfBytes = ligature.maximumLengthOfBytes(using: .utf32)
print ("\(ligature) number of bytes is \(maxNumberOfBytes)") // -> 20
"ﬃ".maximumLengthOfBytes(using: .utf16)
"ﬃ".maximumLengthOfBytes(using: .utf8)

var e = "\u{00E9}"
e.count // -> 1 user perceived character
e.maximumLengthOfBytes(using: .utf32)
e = "e\u{0301}" // append non ligature
e.count // -> 1 user perceived character
e.maximumLengthOfBytes(using: .utf32)
// get the EXACT number of bytes needed to store the String
numberOfBytes = e.lengthOfBytes(using: .utf32)
// Get an ESTIMATE of the maximum number of bytes needed to store the String
// May be considerably greater than the actual length needed, faster than lengthOfBytes(using:)
maxNumberOfBytes = e.maximumLengthOfBytes(using: .utf32)
print ("\(e) number of bytes is \(maxNumberOfBytes)") // -> 8
"\u{00E9}".maximumLengthOfBytes(using: .utf16)
"e\u{0301}".maximumLengthOfBytes(using: .utf8)

var s = "\u{00E9}" // é
var t = "\u{0065}\u{0301}" // e + ´
print("\(t)")
var isEqual : Bool
isEqual = s == t
let equality = isEqual ? "equal" : "not equal"
print ("\(s) is \(equality ) to \(t)") // => é is not equal to e + ´

var bytes = 0
let dogString = "Dog‼🐶"    // !! is one character
for scalar in dogString.unicodeScalars {
    bytes += 4
    print("\(scalar) ")
}
print ("\(dogString) count is \(dogString.count)")
print ("Total Scalar bytes \(bytes)") // Total Scalar bytes 20

var codeUnits = ""
for codeUnit in dogString.utf8 {
    codeUnits += "\(codeUnit)" + " "
}
print ("\(dogString) count is \(dogString.utf8.count)")
print("\(codeUnits) ", terminator: "")
// Prints "68 111 103 226 128 188 240 159 144 182 "
print("")


bytes = 0
var cafeString = "Café"
for scalar in cafeString.unicodeScalars {
    bytes += 4
    print("\(scalar) ")
}
print ("\(cafeString) count is \(cafeString.count)")
print ("Total bytes \(bytes)")
// Total bytes 16
codeUnits = ""
for codeUnit in cafeString.utf16 {
    codeUnits += "\(codeUnit) "
}
print ("\(cafeString) count is \(cafeString.utf8.count)")
print ("\(cafeString) count is \(cafeString.utf16.count*2)")
print ("\(cafeString) count is \(cafeString.unicodeScalars.count*4)")
print("\(codeUnits) ", terminator: "")
print("")
(cafeString as NSString).length

bytes = 0
cafeString = "Cafe\u{0301}"
for scalar in cafeString.unicodeScalars {
    bytes += 4
    print("\(scalar) ")
}
print ("\(cafeString) count is \(cafeString.utf8.count)")
print ("\(cafeString) count is \(cafeString.utf16.count*2)")
print ("\(cafeString) count is \(cafeString.unicodeScalars.count*4)")
print ("\(cafeString) count is \(cafeString.count)")
print ("Total bytes \(bytes)")
// Total bytes 20
codeUnits = ""
for codeUnit in cafeString.utf16 {
    codeUnits += "\(codeUnit) "
}
print("\(codeUnits) ", terminator: "")
print("") // newline
(cafeString as NSString).length



var spain = "España"
spain.count      // 6
spain.unicodeScalars.count  // 6
spain.utf16.count           // 6
spain.utf8.count            // 7


let greeting = "Guten Tag!"
greeting[greeting.startIndex]
// G
greeting[greeting.index(before: greeting.endIndex)]
// !
greeting[greeting.index(after: greeting.startIndex)]
// u
let index = greeting.index(greeting.startIndex, offsetBy: 7)
greeting[index]
// a

let cafe = "Café"
// Unicode safe
let composedCafe = "Café"
let decomposedCafe = "Cafe\u{0301}"
print(cafe.hasPrefix(composedCafe)) // Prints "true"
print(cafe.hasPrefix(decomposedCafe)) // Prints "true"
print(cafe.hasSuffix(decomposedCafe))  // Prints "true"
print(cafe.suffix(1))
print(decomposedCafe.suffix(1))

if let i = cafe.index(of: "é") {
    print (cafe[i])
    print (i)
    let j = i.samePosition(in: cafe.utf8)!
    print (cafe[j])
    print (j)
    print(Array(cafe.utf8[j...]))
    // Prints "[195, 169]"
    print(Array(cafe.utf16[j...]))
    // Prints "[233]"
    print(Array(cafe.unicodeScalars[j...]))
    // Prints "["\\u{00E9}"]"
}

"é".prefix(0)
"a".prefix(1)
"a".prefix(2)
//"a".prefix(-1) // thoughs exception

//"a".infix(from: 1)
"a".infix(from: 0, maxLength: 2)

"a".suffix(0)
"a".suffix(1)
"a".suffix(2)
//"a".suffix(-1) // thoughs exception

let rawInput = "126 a.b 22219 zzzzzz"
let numericPrefix = rawInput.prefix(while: { "0"..."9" ~= $0 })
numericPrefix

var str = String ("Hello, playground")

// don't allow index beond the end
let safeIdx = str.index(str.startIndex, offsetBy: 50, limitedBy: str.endIndex)

var toIndex = str.index(str.endIndex, offsetBy: -4)
var substring = str[..<toIndex]
toIndex = str.index(str.startIndex, offsetBy: 4)
substring = str[..<toIndex]
var range = str.lineRange(for: str.startIndex..<str.index(str.startIndex, offsetBy: 1))

let s1 = "They call me 'Bell'"
let s2 = "They call me 'Stacey'"
print(strncmp(s1, s2, 15))

//str.prefix(-1)  // error
//str.infix(from: -1)   // error
str[2...] // same as infix
str.infix(from: 2)
str.infix(from: 30)
str.infix(from: 16)
str.infix(from: 17)
str.infix(from: 70)
//str.infix(from: -2, maxLength: 0)   // error
//str.infix(from: 0, maxLength: -1)   // error
//str.infix(from: -2, maxLength: -1)   // error
//str.infix(from: 2, maxLength: -1)   // error
str.infix(from: 16, maxLength: 0)
str.infix(from: 16, maxLength: 1)
str.infix(from: 16, maxLength: 10)
str.infix(from: 17, maxLength: 0)
str.infix(from: 17, maxLength: 1)
str.infix(from: 17, maxLength: 10)
str.infix(from: 30, maxLength: 0)
str.infix(from: 30, maxLength: 1)
str.infix(from: 30, maxLength: 10)
str.infix(from: 2, maxLength: 30)
str.infix(from: 7, maxLength: 10)

// make sure from: position is treated as an index so percieved characters are
// parsed and not code points (all the flags are really 1 character in unicode)
var flags = "0123" + String(multipleFlags) + "DEF"
flags.count
flags.length
flags.infix(from: 4)
flags[5...] // same as infix
flags.infix(from: 5)
flags.infix(from: 13)
flags.infix(from: 2, maxLength: 70)
flags.infix(from: 6, maxLength: 4)

var numbers = "3742961"
var positiveInfix = numbers.infix(from: 1, while: { $0 != "6" })
positiveInfix // positiveInfix == "7429"
positiveInfix = numbers.infix(from: 1) { $0 != "6" }  // with while - predicate outside of paramaters
positiveInfix // positiveInfix == "7429"

"🇺🇸".count
"🇺🇸\n".count
"🇺🇸\r".count
"🇺🇸\r\n".count    // \r\n is treatead as 1 glyph in standard UNICODE

"🇺🇸".size
"🇺🇸\n".size
"🇺🇸\r".size
"🇺🇸\r\n".size    // \r\n is treatead as 2 characters in 'size'

// note these are the same as 'size'
"🇺🇸".utf8.count
"🇺🇸\n".utf8.count
"🇺🇸\r".utf8.count
"🇺🇸\r\n".utf8.count    // \r\n is treatead as 2 characters in UTF8

"🇺🇸\r\n".lengthOfBytes(using: .utf8)  // utf8 treats \r\n as 2 characters
"🇺🇸\r\n".lengthOfBytes(using: .utf16) // utf16 treats \r\n as 2 characters
"🇺🇸\r\n".lengthOfBytes(using: .unicode)
"🇺🇸\r\n".lengthOfBytes(using: .ascii)  // ascii requires all characters to be ascii else 0 is returned

// \r\n as a pair is treated as 1 standard UNICODE character but as utf8 it's treated as 2 seperate characters.
// There the only ascii characters to be treated differently in standard UNICODE vs. UTF8.
"\n".count
"\n".size
"\r".count
"\r".size
"\r\n".count // count treats string as Unicode and NOT UTF8 i.e. NOT pure ascii so it's 1 character
"\r\n".size // size treats string as utf8 which treats ALL ascii characters as 1 character
"\r\n".utf8.count // same as 'size'
"\r\n".lengthOfBytes(using: .ascii)
"\r\n".lengthOfBytes(using: .utf16)

"\n\r".count
"\n\r".size
"\n\r\r\n".count
"\n\r\r\n".size

numbers = "12\n34\n"
numbers.count
numbers.size
numbers.length  // length in utf16 code points which uses 2 bytes for each code point
numbers.lengthOfBytes(using: .utf16)    // basically the same as (numbers.length * 2)

"🇺🇸".isAscii
"🇺🇸abc".isAscii
"abc".isAscii
"".isAscii

