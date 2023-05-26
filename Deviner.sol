// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
    
    contract Deviner is Ownable{
        
        address[] public resetplayer; // Permet la reinit des joueurs
        struct Game {
            string mot;
            string indice;
        }

        struct Player {
            string nom;
            bool isRegistered;
            bool isPlayed;
            bool isCorrect;
        }

        Game[] public games;
        mapping(address=>Player) public players;
        
        modifier isRegistered {
            require(players[msg.sender].isRegistered, "Account not Exist, create account first");
            _;
        }

        modifier alreadyRegistered{
            require(!players[msg.sender].isRegistered, "Account already Exist");
            _;
        }

        modifier alreadyPlayed{
             require(players[msg.sender].isPlayed == false, "Already played Game");
            _;
        }

        function addWordAndIndice(string memory _mot, string memory _indice) external onlyOwner {
            Game memory game = Game(_mot, _indice);
            games.push(game);
        }

        modifier isPossibleToPlay{
            require(games.length > 0, "No data to play for the moment");
            _;
        }

        function resetGame() external onlyOwner {
            // Supprimer l'entrée dans le tableau
            // Mettre tous les joueurs dans le mapping à False
        }

        function displayIndice() external isPossibleToPlay view returns(string memory){
            return games[0].indice;
        }

        function addPlayer(string memory _nom) external alreadyRegistered{
            require(bytes(_nom).length > 0, "You need enter a name");
            Player storage player = players[msg.sender];
            player.isRegistered = true;
            player.nom = _nom;
            // On met dans le tab d uint l'adresse
            resetplayer.push(msg.sender);
        }

        function _isWordMatch(string memory _mot) private view returns(bool){
            if (keccak256(abi.encodePacked(games[0].mot)) == keccak256(abi.encodePacked(_mot)))  
            { return true; } else { return false; }
           
        }

        function playGame (string memory _mot) external isRegistered isPossibleToPlay alreadyPlayed{
            require(bytes(_mot).length > 0, "You need enter a word");
            Player storage player = players[msg.sender];
            player.isPlayed = true;
            player.isCorrect = _isWordMatch(_mot);
        }

        // Diplay Winner if exist
        function getWinner() external view returns(string memory) {   
            string memory listewinner;
            for (uint i=0; i < resetplayer.length; i++){
                if ( players[ resetplayer[i] ].isCorrect == true ) {
                    listewinner = players[resetplayer[i]].nom;
                }
            }
            return listewinner;
        }


    }