import Cocoa
import Swift

var str = "Hello, playground"
var subStr = str[str.index(after: str.startIndex)..<str.index(before: str.endIndex)]
var students = ["Ben", "Ivy", "Jordell", "Maxime"]
if let i = students.firstIndex(of: "Ben") {
    print (i)

    students[i] = "Max"
}
print(students)


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
