
import Foundation

struct Question: Codable {
    var question: String
    var choices: [String]
    var answers: Set<String>
    
    var answerIndexs: Set<Int> {
        Set(choices.indices.filter( { index in
            answers.contains(choices[index])
        }))
    }
}

var questions = [
    Question(question: "谁是世界上最可爱的人?", choices: ["军人", "农民", "教师"], answers: ["军人", "农民", "教师"]),
    Question(question: "1+1=?", choices: ["1", "2", "3"], answers: ["2"])
]


