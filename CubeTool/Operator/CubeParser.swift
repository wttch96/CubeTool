//
//  CubeParser.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/23.
//

enum CubeParser {
    /// 解析给定公式字符串并返回操作序列
    static func parseMoves(from formula: String) -> [CubeMove] {
        var moves: [CubeMove] = []
        var i = formula.startIndex
        
        while i < formula.endIndex {
            let char = String(formula[i])
            var move: CubeMove?
            
            if char == "(" {
                // 处理括号中的操作组
                let endIndex = findClosingBracket(in: formula, from: i)
                let groupMoves = parseMoves(from: String(formula[formula.index(after: i) ..< endIndex]))
                i = endIndex
                
                // 检查是否有修饰符，重复整个组
                if i < formula.index(before: formula.endIndex) {
                    let nextChar = String(formula[formula.index(after: i)])
                    if nextChar == "2" {
                        moves.append(contentsOf: groupMoves)
                        moves.append(contentsOf: groupMoves) // 重复组内的操作
                        i = formula.index(after: i) // 跳过重复符号
                    } else {
                        moves.append(contentsOf: groupMoves)
                    }
                } else {
                    moves.append(contentsOf: groupMoves)
                }
            } else if let baseMove = CubeMove(rawValue: char) {
                move = baseMove
            }
            
            // 同样处理反向操作和重复操作
            if i < formula.index(before: formula.endIndex) {
                let nextChar = String(formula[formula.index(after: i)])
                if nextChar == "'" {
                    if let baseMove = CubeMove(rawValue: char + "'") {
                        move = baseMove
                    }
                    i = formula.index(after: i)
                } else if nextChar == "2" {
                    if let baseMove = CubeMove(rawValue: char) {
                        moves.append(baseMove)
                        moves.append(baseMove)
                    }
                    i = formula.index(after: i)
                    move = nil
                }
            }
            
            if let move = move {
                moves.append(move)
            }
            
            i = formula.index(after: i)
        }
        
        return moves
    }
    
    /// 查找与给定索引处的左括号匹配的右括号
    static func findClosingBracket(in formula: String, from startIndex: String.Index) -> String.Index {
        var openBrackets = 0
        var i = startIndex
        
        while i < formula.endIndex {
            if formula[i] == "(" {
                openBrackets += 1
            } else if formula[i] == ")" {
                openBrackets -= 1
                if openBrackets == 0 {
                    return i
                }
            }
            i = formula.index(after: i)
        }
        
        return formula.endIndex // 如果没有找到匹配的括号，返回字符串末尾
    }
    
    static func executeMoves(_ moves: [CubeMove]) {
        for move in moves {
            move.apply()
        }
    }
}
