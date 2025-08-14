@testable import Geometry
import Testing

@Test func with2NeighborElements() throws {
    let array = [0, 1, 2, 3]
    let array2 = array.with2NeighborElements()
    #expect(array2.count == array.count)
    #expect(array2[0] == (3, 0, 1))
    #expect(array2[1] == (0, 1, 2))
    #expect(array2[2] == (1, 2, 3))
    #expect(array2[3] == (2, 3, 0))
}
