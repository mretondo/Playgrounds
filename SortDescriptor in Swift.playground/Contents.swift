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

/// Combines multiple sort descriptors into a single sort descriptor.
/// First it tries the first descriptor and uses that comparison result.
/// However, if the result is equal, it uses the second descriptor, and
/// so on, until we run out of descriptors.
/// - Parameter sortDescriptors: [SortDescriptor]
func combine<Root> (sortDescriptors: [SortDescriptor<Root>]) -> SortDescriptor<Root>
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
/// Example:
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

