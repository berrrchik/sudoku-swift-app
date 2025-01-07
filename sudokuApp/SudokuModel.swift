import Foundation

struct SudokuModel: Decodable {
    struct Grid: Decodable {
        let value: [[Int]]
        let solution: [[Int]]
        let difficulty: String
    }
    
    let newboard: NewBoard
    
    struct NewBoard: Decodable {
        let grids: [Grid]
        let results: Int
        let message: String
    }
}
