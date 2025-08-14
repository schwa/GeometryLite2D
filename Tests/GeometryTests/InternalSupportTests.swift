@testable import Geometry
import Testing

@Test
func testWithNeighborElements() {
    let array = [1, 2, 3, 4]
    let pairs = array.withNeighborElements()
    #expect(pairs.count == 4)
    #expect(pairs[0] == (1, 2))
    #expect(pairs[1] == (2, 3))
    #expect(pairs[2] == (3, 4))
    #expect(pairs[3] == (4, 1))
}

@Test
func testWithNeighborElementsEmpty() {
    let array: [Int] = []
    let pairs = array.withNeighborElements()
    #expect(pairs.isEmpty)
}

@Test
func testWith2NeighborElements() {
    let array = [1, 2, 3, 4]
    let triplets = array.with2NeighborElements()
    #expect(triplets.count == 4)
    #expect(triplets[0] == (4, 1, 2))
    #expect(triplets[1] == (1, 2, 3))
    #expect(triplets[2] == (2, 3, 4))
    #expect(triplets[3] == (3, 4, 1))
}

@Test
func testWith2NeighborElementsEmpty() {
    let array: [Int] = []
    let triplets = array.with2NeighborElements()
    #expect(triplets.isEmpty)
}

@Test
func testUniqued() {
    let array = [1, 2, 2, 3, 1, 4, 3]
    let unique = array.uniqued()
    #expect(unique == [1, 2, 3, 4])
}

@Test
func testUniquedEmpty() {
    let array: [Int] = []
    let unique = array.uniqued()
    #expect(unique.isEmpty)
}
