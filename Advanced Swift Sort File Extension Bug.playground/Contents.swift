import Foundation

//
// Swift version of Foundations NSSortDescriptor
//

/// A sorting predicate that returns `true` if the first
/// value should be ordered before the second.
typealias SortDescriptor<Root> = (Root, Root) -> Bool

// Function that return a Boolean value, because that's the standard library's convention for comparison predicates
func sortDescriptor<Root, Value>(
    key: @escaping (Root) -> Value,
    by areInIncreasingOrder: @escaping (Value, Value) -> Bool) -> SortDescriptor<Root>
{
    return { areInIncreasingOrder(key($0), key($1)) }
}

// Overloaded variant of above function that works for all Comparable types
func sortDescriptor<Root, Value>( key: @escaping (Root) -> Value) -> SortDescriptor<Root>
    where Value: Comparable
{
    return { key($0) < key($1) }
}

// Overloaded variant of above functions for Foundation APIs like localizedStandardCompare which
// expect a three-way ComparisonResult value instead (ordered ascending, descending, or equal)
func sortDescriptor<Root, Value>(
    key: @escaping (Root) -> Value,
    ascending: Bool = true,
    by comparator: @escaping (Value) -> (Value) -> ComparisonResult) -> SortDescriptor<Root>
{
    return { lhs, rhs in
        let order: ComparisonResult = ascending ? .orderedAscending : .orderedDescending
        return comparator(key(lhs))(key(rhs)) == order
    }
}

// Function that combines multiple sort descriptors into a single sort descriptor.
//
// First it tries the first descriptor and uses that comparison result. However, if the result is equal,
// it uses the second descriptor, and so on, until we run out of descriptors.
func combineSortDescriptors<Root> (_ sortDescriptors: [SortDescriptor<Root>]) -> SortDescriptor<Root>
{
    return { lhs, rhs in
        for areInIncreasingOrder in sortDescriptors {
            if areInIncreasingOrder(lhs, rhs) {
                return true
            }

            if areInIncreasingOrder(rhs, lhs) {
                return false
            }
        }

        return false
    }
}

// Take a regular comparison function such as localizedStandardCompare, which works
// on two strings, and turn it into a function that takes two optional strings
func lift<A>(_ compare: @escaping (A) -> (A) -> ComparisonResult) -> (A?) -> (A?) -> ComparisonResult
{
    return { lhs in { rhs in
        switch (lhs, rhs) {
        case (nil, nil): return .orderedSame
        case (nil, _): return .orderedAscending
        case (_, nil): return .orderedDescending
        case let (l?, r?): return compare(l)(r)
        }
    } }
}


@objcMembers
final class Person: NSObject
{
    let first: String
    let last: String
    let yearOfBirth: Int

    init(first: String, last: String, yearOfBirth: Int)
    {
        self.first = first
        self.last = last
        self.yearOfBirth = yearOfBirth
        // super.init() implicitly called here
    }

    override var debugDescription: String {
        return first + " " + last + " " + String(yearOfBirth)
    }
}

extension Person
{
    override var description: String { "\(first) \(last) \(yearOfBirth)" }
}

//
// Define an array of people with different names and birth years
//
let people = [
    Person(first: "Emily",  last: "Young",  yearOfBirth: 2002),
    Person(first: "David",  last: "Gray",   yearOfBirth: 1991),
    Person(first: "Robert", last: "Barnes", yearOfBirth: 1985),
    Person(first: "Ava",    last: "Barnes", yearOfBirth: 2000),
    Person(first: "Joanne", last: "Miller", yearOfBirth: 1994),
    Person(first: "Ava",    last: "Barnes", yearOfBirth: 1998),
]

let sortByYear: SortDescriptor<Person> = sortDescriptor(key: { $0.yearOfBirth })
let sortByFirstName: SortDescriptor<Person> = sortDescriptor(key: { $0.first }, by: String.localizedStandardCompare)
let sortByLastName: SortDescriptor<Person> = sortDescriptor(key: { $0.last }, by: String.localizedStandardCompare)
var combinedSortDescriptors: SortDescriptor<Person> = combineSortDescriptors( [sortByLastName, sortByFirstName, sortByYear] )
let orderedPeople = people.sorted(by: combinedSortDescriptors).description

let sortByYearGreaterThan: SortDescriptor<Person> = sortDescriptor(key: { $0.yearOfBirth }, by: >)
combinedSortDescriptors = combineSortDescriptors( [sortByLastName, sortByFirstName, sortByYearGreaterThan] )
//print (people)
people.sorted(by: combinedSortDescriptors).description


//
// example of sorting Finder names by only their extension
//
extension String {
    var fileExtension: String? {
        guard let period = lastIndex(of: ".") else { return nil }

        let extensionStart = index(after: period)
        return String(self[extensionStart...])
    }
}

//
// Sort Finder filenames only by their extensions
// Missing extensions come first i.e. "file", then by empty extensions i.e. "file.” and finally by extensions
//
var files = ["file.swift", "one", "two", "test.h", "three", "file.h", "file.", "file.c"]

//
// sort() pass parms to the Closures as (right, left) not (left, right), weird
//
files.sort { r, l in
    // don't swap items if both don't have extensions
    if l.fileExtension == nil && r.fileExtension == nil {
        return false
    }

    // if file on the right has no extension it comes first
    if r.fileExtension == nil {
        return true
    }

    // if file on the left has no extension it comes first
    if l.fileExtension == nil {
        return false
    }

    return l.fileExtension.flatMap { r.fileExtension?.localizedStandardCompare($0) } == .orderedAscending
}
files // ["one", "two", "three", "file.", "file.c", "test.h", "file.h", "file.swift"]



