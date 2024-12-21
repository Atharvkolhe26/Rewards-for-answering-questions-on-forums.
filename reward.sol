// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ForumRewards {
    struct Question {
        string content;
        address asker;
        uint256 reward;
        bool isAnswered;
    }

    struct Answer {
        string content;
        address responder;
    }

    Question[] public questions;
    mapping(uint256 => Answer[]) public answers;

    event QuestionPosted(uint256 id, string content, address indexed asker, uint256 reward);
    event AnswerPosted(uint256 questionId, string content, address indexed responder);
    event RewardClaimed(uint256 questionId, address indexed responder, uint256 reward);

    function postQuestion(string memory _content) public payable {
        require(msg.value > 0, "Reward must be greater than zero");
        questions.push(Question(_content, msg.sender, msg.value, false));
        emit QuestionPosted(questions.length - 1, _content, msg.sender, msg.value);
    }

    function postAnswer(uint256 _questionId, string memory _content) public {
        require(_questionId < questions.length, "Question does not exist");
        require(!questions[_questionId].isAnswered, "Question is already answered");

        answers[_questionId].push(Answer(_content, msg.sender));
        emit AnswerPosted(_questionId, _content, msg.sender);
    }

    function selectBestAnswer(uint256 _questionId, uint256 _answerId) public {
        require(_questionId < questions.length, "Question does not exist");
        Question storage question = questions[_questionId];
        require(msg.sender == question.asker, "Only the asker can select the best answer");
        require(!question.isAnswered, "Question is already answered");
        require(_answerId < answers[_questionId].length, "Answer does not exist");

        question.isAnswered = true;
        address responder = answers[_questionId][_answerId].responder;
        payable(responder).transfer(question.reward);
        emit RewardClaimed(_questionId, responder, question.reward);
    }

    // Function to check the balance of the contract
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}