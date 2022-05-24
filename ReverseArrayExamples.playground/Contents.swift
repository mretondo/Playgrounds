//
// reverse range
//
print()
let a = 0...10
for i in a.reversed() {
    print(i)
}

let reversedCollection = (0 ..< 6).reversed()
for i in reversedCollection {
    print(i)
}

//
// reverse array using stride
//
let intArray = [0, 1, 2, 3, 4 ,5]
var reverseArr = [Int]()
for i in stride(from: intArray.count-1, to: -1, by: -1){
    reverseArr.append(intArray[i])
}
print ("Use stride: \(reverseArr)")

// reverse with iterator
extension Int {
    func iterateDown(To endIndex: Int) -> AnyIterator<Int> {
        var index = self
        guard index >= endIndex else { fatalError("not >= to endIndex") }
        let iter = AnyIterator { () -> Int? in
            defer { index -= 1 }
            return index >= endIndex ? index : nil
        }
        return iter
    }
}
print("")
let iterator = 10.iterateDown(To: 0)
for index in iterator {
    print("iterateDown(To: 0) \(index)")
}

//
// reverse string
//
let word = "Backwards"
for char in word.reversed() {
    print(char, terminator: "") // terminator prevents newline i.e. sdrawkcaB
}
// Prints "sdrawkcaB"

//
// Returns a new array with the contents of this sequence, shuffled
//
extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled i.e. random.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

//
// Returns an ARRAY of strings with the contents of this sequence, shuffled
// "Backwards" -> ["s", "d", "r", "a", "w", "c", "a", "k", "B"]
//
print()
let w = "Backwards"
print("'Backwards' shuffled: \(w.shuffled())") //  calls Sequence extension shuffled
// Prints ["s", "d", "r", "a", "w", "c", "a", "k", "B"]

//
// convert string to [Character] and shuffle it then convert back to string
//
print()
var strHello = "Hello"
var charArray = Array(strHello)
charArray.shuffled() // [Character]
var shuffledString = String(charArray)
print(shuffledString)
print(String("Hello".shuffled())) // one liner calls Sequence extension shuffled
//print ("leHol or similar")

//
// use Array.shuffle()
// convert string to [String.Element] then shuffle it then convert back to string
//
print()
let strApple = "Apple"
var strArray = Array(strApple)
strArray.shuffle()
let shuffledStr = String(strArray)
print(shuffledStr)
// shuffledWord = “pAelp” or similar

//
// Sort arrary then reverse it
//
print()
let nums = [100, 5, 53, 98, 29]
let srt = Array(nums.sorted())
let reversed1 = Array(srt.reversed())
print(reversed1)
// prints [5, 29, 53, 98, 100]

//
// Reverse [String]
//
print()
let names: [String] = ["Apple", "Microsoft", "Sony", "Lenovo", "Asus"]
var reversedNames = [String]()
for arrayIndex in stride(from: names.count - 1, through: 0, by: -1) {
    reversedNames.append(names[arrayIndex])
}
print(reversedNames)

//
// reverse array in place
//
print()
var names1:[String] = [ "A", "B", "C", "D", "E","F","G"]
var count = names1.count - 1
var idx = 0
while idx < count {
    names1.swapAt(idx, count)
    idx = idx + 1
    count = count - 1
}
print("Reversed in place: \(names1)")

print()
var numArrary:[Int] = [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
var cnt = numArrary.count - 1
var i = 0
while i < cnt {
    numArrary.swapAt(i, cnt)
    i += 1
    cnt -= 1
}
print("Reversed in place: \(numArrary)")

