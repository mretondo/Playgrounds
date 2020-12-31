import Foundation

//
// Swift version of Foundations NSSortDescriptor but Type safe
//

// A sorting predicate that returns `true` if the first
// value should be ordered before the second.
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

// Overloaded variant of above functions for Foundation APIs like String:localizedStandardCompare(_:)
// which expect a three-way ComparisonResult value instead (ordered ascending, descending, or equal)
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

/// Combines multiple sort descriptors into a single sort descriptor.
/// First it tries the first descriptor and uses that comparison result.
/// However, if the result is equal, it uses the second descriptor, and
/// so on, until we run out of descriptors.
/// - Parameter sortDescriptors: [SortDescriptor]
func combineSortDescriptors<Root> (using sortDescriptors: [SortDescriptor<Root>]) -> SortDescriptor<Root>
{
    return { lhs, rhs in
        for areInIncreasingOrder in sortDescriptors {
            if areInIncreasingOrder(lhs, rhs) {
                return true
            }

            // flip lhs and rhs order
            if areInIncreasingOrder(rhs, lhs) {
                return false
            }
        }

        return false
    }
}

///
/// lift() allows us to “lift” a regular comparison function into the domain of optionals, and
/// it can be used together with our sortDescriptor function. It takes a regular comparison
/// function such as String:localizedStandardCompare(_:), which works on two objects, 'self'
/// and the object passed to it. It then turns it into a function that takes two optional
/// objects e.g. (lhs: String?, rhs: String?) -> ComparisonResult.
///
/// - Example:
/// extension String {
///     var fileExtension: String? {
///         guard let period = lastIndex(of: ".") else { return nil }
///
///         let extensionStart = index(after: period)
///         return String(self[extensionStart...])
///     }
/// }
///
///  var files = ["file.swift", "one", "two", "test.h", "three", "file.h", "file.", "file.c"]
///  let compare = lift(String.localizedStandardCompare)
///      'compare(lhs: String?, rhs: String?) -> ComparisonResult'
///  let result = files.sorted(by: sortDescriptor(key: { $0.fileExtension }, by: compare))
///      result equals ["one", "two", "three", "file.", "file.c", "test.h", "file.h", "file.swift"]
///
/// - Parameter compare: a regular comparison compare function such as String:localizedStandardCompare(_:)
/// - Returns: A ComparisonResult.
func lift<A>(_ compare: @escaping (A) -> (A) -> ComparisonResult) -> (A?) -> (A?) -> ComparisonResult
{
    return { lhs in { rhs in
        switch (lhs, rhs) {
            case (nil, nil): return .orderedSame
            case (nil, _): return .orderedAscending
            case (_, nil): return .orderedDescending
            case let (l?, r?): return compare(l)(r)
        }
    }}
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

var combinedSortDescriptors: SortDescriptor<Person> = combineSortDescriptors(using: [sortByLastName, sortByFirstName, sortByYear] )
let orderedPeople = people.sorted(by: combinedSortDescriptors).description

// sort desending by year
let sortByYearGreaterThan: SortDescriptor<Person> = sortDescriptor(key: { $0.yearOfBirth }, by: >)
combinedSortDescriptors = combineSortDescriptors(using: [sortByLastName, sortByFirstName, sortByYearGreaterThan] )
people.sorted(by: combinedSortDescriptors).description


//
// Sort Finder filenames only by their extensions
// Missing extensions come first i.e. "file", then by empty extensions i.e. "file.” and finally by extensions
//
extension String {
    var fileExtension: String? {
        guard let period = lastIndex(of: ".") else { return nil }

        let extensionStart = index(after: period)
        return String(self[extensionStart...])
    }
}

var files = ["file.swift", "one", "two", "test.h", "three", "file.h", "file.", "file.c"]
let compare = lift(String.localizedStandardCompare)
let result = files.sorted(by: sortDescriptor(key: { $0.fileExtension }, by: compare))
result // ["one", "two", "three", "file.", "file.c", "test.h", "file.h", "file.swift"]

// sort 'files' in place
files.sort { e0, e1 in
    // don't swap items if both don't have extensions
    if e1.fileExtension == nil && e0.fileExtension == nil {
        return false
    }

    // if file on the right has no extension it comes first
    if e0.fileExtension == nil {
        return true
    }

    // if file on the left has no extension it comes first
    if e1.fileExtension == nil {
        return false
    }

    return e1.fileExtension.flatMap { e0.fileExtension?.localizedStandardCompare($0) } == .orderedDescending
}
files // ["one", "two", "three", "file.swift", "test.h", "file.h", "file.c", "file."]



