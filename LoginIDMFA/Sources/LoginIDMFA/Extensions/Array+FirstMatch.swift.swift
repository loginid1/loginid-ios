//
//  Array+FirstMatch.swift.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-12.
//

extension Array where Element: Hashable {
    /**
     Returns the first element from the current array that also exists in the
     given `ordered` array, preserving the order of the `ordered` array.
     
     - Parameter ordered: The array whose element order determines priority for the match.
     - Returns: The first matching element found in both arrays, or `nil` if no match exists.
     */
    func firstMatch(in ordered: [Element]) -> Element? {
        let set = Set(self)
        return ordered.first(where: set.contains)
    }
}
