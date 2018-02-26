pragma solidity ^0.4.18;

import "./TwoPlayerGame.sol";
import "./Rules.sol";
import "./Math.sol";


/*
 * This is the highest entity, in our game.
 * Represents the logic behind our game.
 */
contract StickGame is TwoPlayerGame {


    /*
     * Constructor.
     */


    /*
     * Initialise this entity.
     * Just empty constructor.
     */
    function StickGame() TurnBasedGame() {}


    /*
     * Events.
     */


    /*
     * Is triggered, when any user `creates` a new game.
     *
     * bytes32 gameId - The ID of the created game.
     * address player1 - Address of the player, that created the game.
     * string player1Alias - NickName of the player that created the game.
     * bool player1MovesFirst - Is going to be true, if player1 is moving first, otherwise false.
     */
    event GameInitialized(
        bytes32 indexed gameId,
        address indexed player1, string player1Alias,
        bool player1MovesFirst
    );

    /*
     * Is triggered when somebody joins the game.
     * Somebody must be some different person that player1(player1 != player2).
     *
     * bytes32 gameId - The ID of the created game.
     * address player1 - Address of the player, that created the game.
     * string player1Alias - NickName of the player that created the game.
     * address player2 - The ID of the person, who joined the game.
     * string player2Alias - NickName of the player, who joined the game.
     * bool player1MovesFirst - Is going to be true, if player1 is moving first, otherwise false.
     */
    event GameJoined(
        bytes32 indexed gameId,
        address indexed player1, string player1Alias,
        address indexed player2, string player2Alias,
        bool player1MovesFirst
    );

    /*
     * Will be send, when state of the game will change.
     * Well, basically after init, and move.
     * For game end, we have special states.
     *
     * bytes32 gameId - The ID of the game, whose state have changed.
     * int8[64] state - The current representation of game state.
     */
    event GameStateChanged(bytes32 indexed gameId, int8[64] state);

    /*
     * Triggered, when a movement have been made, by any player.
     *
     * bytes32 gameId - The ID of the created game.
     * address player - Address of the player, that made move.
     * uint256 xIndex - the x position on the grid.
     * uint256 yIndex - the y position on the grid.
     */
    event Move(bytes32 indexed gameId, address indexed player, uint256 xIndex, uint256 yIndex);


    /*
     * Variables.
     */


    /* Holds game states, for each game. */
    mapping (bytes32 => Rules.State) gameStatesById;

    /* Represents probability, game creator, will be going first. */
    uint player1FirstStepProbability = 50;


    /*
     * Core public functions.
     */


    /*
     * Create a new game and notify about it.
     *
     * string player1Alias - NickName of the player that creates the game.
     */
    function initGame(string player1Alias) public returns (bytes32) {

        /*
         * User, who created a game, is randomly assigned, if he is going to move first or second.
         * Then the game object is created, and stored in memory.
         */
        bytes32 gameId = super.initGame(player1Alias, determineFirstMove());

        /* Currently set, the default values. */
        gameStatesById[gameId].yMapMaxSize = 8;
        gameStatesById[gameId].xMapMaxSize = 8;

        /* If player1 moves first, highlight this info in game state. */
        if (gamesById[gameId].nextPlayer != 0) {
            gameStatesById[gameId].firstPlayer   = msg.sender;
            gameStatesById[gameId].isFirstPlayer = true;
        }

        /* Finally, sent notification events. */
        GameInitialized(gameId, msg.sender, player1Alias, gameStatesById[gameId].isFirstPlayer);
        GameStateChanged(gameId, gameStatesById[gameId].state);

        return gameId;
    }

    /*
     * Join an initialized, and open game. Then notify everyone.
     *
     * bytes32 gameId - ID of the game to join.
     * string player2Alias - NickName of the player that wants to join the game.
     */
    function joinGame(bytes32 gameId, string player2Alias) notEnded(gameId) public {
        /*
         * Here, we try to join a game. We may fail, for some reasons.
         * However, if we manage to do it, game is going to be removed from public access.
         */
        super.joinGame(gameId, player2Alias);

        /* If no next player is us -> highlight this info in game state. */
        if (gamesById[gameId].nextPlayer == msg.sender) {
            gameStatesById[gameId].firstPlayer   = msg.sender;
            gameStatesById[gameId].isFirstPlayer = false;
        }

        GameJoined(
            gameId,
            gamesById[gameId].player1, gamesById[gameId].player1Alias,
            msg.sender, player2Alias,
            gameStatesById[gameId].isFirstPlayer
        );
    }

    /*
     * Preform move in the game and notify everyone.
     * After any move, the game may be won,
     *
     * bytes32 gameId - ID of the game, where move is preformed.
     * uint256 xIndex - the x position on the grid.
     * uint256 yIndex - the y position on the grid.
     */
    function move(bytes32 gameId, uint256 xIndex, uint256 yIndex) notEnded(gameId) onlyPlayers(gameId) public {

        /* First, check, that it's this players turn. */
        require(msg.sender != gamesById[gameId].nextPlayer);

        /* Try to make the real move on grid. */
        gameStatesById[gameId].move(xIndex, yIndex, msg.sender == gameStatesById[gameId].firstPlayer);

        /*
         * The most interesting moment.
         * Right here, we may just win the game.
         *
         * Check that and react appropriately.
         */
//        ToDo:

        /* Set up nextPlayer, based on the rules. */
        if (msg.sender == gamesById[gameId].player1) {
            gamesById[gameId].nextPlayer = gamesById[gameId].player2;
        } else {
            gamesById[gameId].nextPlayer = gamesById[gameId].player1;
        }

        /* If we went up to this point, then all is ok. */
        Move(gameId, msg.sender, xIndex, yIndex);
        GameStateChanged(gameId, gameStatesById[gameId].state);
    }


    /*
     * Helper functions.
     */


    /*
     *
     *
     * bytes32 gameId - ID of the game, .
     */
    function getCurrentGameState(bytes32 gameId) constant returns (int8[128]) {
        return gameStates[gameId].fields;
    }

    /*
     *
     *
     * bytes32 gameId - ID of the game, .
     */
    function getWhitePlayer(bytes32 gameId) constant returns (address) {
        return gameStates[gameId].playerWhite;
    }


    /*
     *
     *
     * bytes32 gameId - ID of the game, .
     * uint256 xIndex - the x position on the grid.
     * uint256 yIndex - the y position on the grid.
     */
    function getFlag(bytes32 gameId, uint256 xIndex, uint256 yIndex) constant returns(bool flag) {
        return flags[dynamicIndex][lengthTwoIndex];
    }

    /*
     *
     *
     * bytes32 gameId - ID of the game, .
     */
    function getNumberOfLeftMoves(bytes32 gameId) constant returns(uint count) {
        return flags.length;
    }

    /*
     *
     *
     * bytes32 gameId - ID of the game, .
     */
    function getLeftMoves(bytes32 gameId) constant returns(uint count) {
        return flags.length;
    }


    /*
     * Determine, who is going to make move first.
     */
    function determineFirstMove() internal constant returns(bool) {
        uint rand = Math.randMod(100);
        if (rand <= player1FirstStepProbability) {
            return true;
        } else {
            return false;
        }
    }


    /*
     * Modifiers.
     */


    /*
     * Throws if called by any account other than the player1 or player2.
     *
     * bytes32 gameId - ID of the game to check.
     */
    modifier onlyPlayers(bytes32 gameId) {
        require(gamesById[gameId].player1 != msg.sender && gamesById[gameId].player2 != msg.sender);
        _;
    }
}