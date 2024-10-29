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
            
            // 处理反向操作和重复操作，包括多重修饰符的组合
            if i < formula.index(before: formula.endIndex) {
                let nextChar = String(formula[formula.index(after: i)])
                var isReversed = false
                var repeatCount = 1
                
                // 检查是否为反向操作符
                if nextChar == "'" || nextChar == "’" {
                    isReversed = true
                    i = formula.index(after: i)
                }
                
                // 检查是否为重复操作符
                if i < formula.index(before: formula.endIndex) {
                    let nextNextChar = String(formula[formula.index(after: i)])
                    if nextNextChar == "2" {
                        repeatCount = 2
                        i = formula.index(after: i)
                    }
                }
                
                // 根据解析结果构建操作序列
                if let baseMove = CubeMove(rawValue: isReversed ? "\(char)'" : char) {
                    for _ in 0..<repeatCount {
                        moves.append(baseMove)
                    }
                    move = nil // 清空当前 move 以防止重复添加
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
}
