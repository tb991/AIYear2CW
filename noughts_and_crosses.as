//imports
import flash.events.MouseEvent;
import flash.display.IBitmapDrawable;

//enforcement
alertOK_mc.visible = false;
clever_mc.gotoAndStop(2); // by default the computer moves randomly
rc00_mc.gotoAndStop(1);
rc01_mc.gotoAndStop(1);
rc02_mc.gotoAndStop(1);
rc10_mc.gotoAndStop(1);
rc11_mc.gotoAndStop(1);
rc12_mc.gotoAndStop(1);
rc20_mc.gotoAndStop(1);
rc21_mc.gotoAndStop(1);
rc22_mc.gotoAndStop(1);
info_field.output.text = "Click me for help.";

//listeners for playing
rc00_mc.addEventListener(MouseEvent.MOUSE_UP, choose_this_tile);
rc01_mc.addEventListener(MouseEvent.MOUSE_UP, choose_this_tile);
rc02_mc.addEventListener(MouseEvent.MOUSE_UP, choose_this_tile);
rc10_mc.addEventListener(MouseEvent.MOUSE_UP, choose_this_tile);
rc11_mc.addEventListener(MouseEvent.MOUSE_UP, choose_this_tile);
rc12_mc.addEventListener(MouseEvent.MOUSE_UP, choose_this_tile);
rc20_mc.addEventListener(MouseEvent.MOUSE_UP, choose_this_tile);
rc21_mc.addEventListener(MouseEvent.MOUSE_UP, choose_this_tile);
rc22_mc.addEventListener(MouseEvent.MOUSE_UP, choose_this_tile);
//other listeners
alertOK_mc.alertButton.addEventListener(MouseEvent.MOUSE_UP, alertOK_off);
alertOK_mc.alertButton.addEventListener(MouseEvent.MOUSE_UP, alertOK_acknowledged);
clever_mc.addEventListener(MouseEvent.MOUSE_UP, change_clever);
newgame_btn.addEventListener(MouseEvent.MOUSE_UP, newgame);
info_field.addEventListener(MouseEvent.MOUSE_UP, cycle_hints);

//global variables
var board: Array = [
	["-", "-", "-"],
	["-", "-", "-"],
	["-", "-", "-"]
];
var winner: int = 0;
var optimalMove: Array = new Array(3); // used in the search algorithm
var helpClicks: int = 0;
var totalHints: int = 3 //const
var allMoveChoices: Array = new Array(); // contains all potential boards for the computer's next move
var currentPotentialBoard = new Array(); // the current potential board/move being processed

////functions
function playIntelligent(): void {
	// do a breadth first search to one level
	// apply the heuristic function to each potential board
	// select the move with the best utility
	var i: int;
	var j: int;
	var moves: Array = allMoves();
	var eachUtility: Array = new Array();
	var numUtils: int = 0;
	for (i = 0; i < moves.length; i++) {
		var utility: int;
		utility = 3 * XAndOs(moves[i], 2, 0) + XAndOs(moves[i], 1, 0) - 3 * XAndOs(moves[i], 0, 2) - XAndOs(moves[i], 0, 1) + optimal(moves[i], "O") + emergency(moves[i], "O");
		/*trace(moves[i]);
		var hValues:Array = [XAndOs(moves[i], 2, 0),XAndOs(moves[i], 1, 0),XAndOs(moves[i], 0, 2),XAndOs(moves[i], 0, 1)]
		trace(hValues);
		trace();*/
		trace(utility);
		eachUtility[numUtils] = utility;
		numUtils++;
	}
	// now find the index of the best move
	var minFinder: int;
	var moveIndex: int; // large so it will definitely be reset
	var min: int = 100;
	for (minFinder = 0; minFinder < eachUtility.length; minFinder++) {
		if (eachUtility[minFinder] < min) {
			min = eachUtility[minFinder];
			moveIndex = minFinder;
		}
	}
	//trace(moves[moveIndex]);
	// now extract the row and column
	// by having two arrays of the old board and the new board and detecting where there is a new "O"
	var row: int;
	var col: int;
	for (i = 0; i < 3; i++) {
		for (j = 0; j < 3; j++) {
			// the following statement should only occur once
			if (board[i][j] == "-" && moves[moveIndex][i][j] == "O") {
				row = i;
				col = i;
			}
		}
	}
	//trace(row, col);
	board = moves[moveIndex];
	updateBoard();
	// now check the winner
	fullCheck();
	//trace(boardcheck());
}

function optimal(theBoard:Array, turn:String):int{
	if (turn=="O"){
		if (XAndOs(theBoard, 0,3) > 0){
			return -100; // if there's a winning opportunity then force this square to be taken
		}
	}
	return 0;
}
function emergency(theBoard:Array, turn:String){
	if (turn=="O"){
		if (XAndOs(theBoard, 2,1) > 0){
			return -100; // if there's a winning opportunity then force this square to be taken
		}
	}
	return 0;
}
function fullCheck():void{
	if (checkWinner() == 1) {
		alertOK_mc.visible = true;
		alertOK_mc.alertText.text = "Congratulations, you won! Click NewGame to play again";
		winner = 1;
		return;
	} else if (checkWinner() == 2) {
		alertOK_mc.visible = true;
		alertOK_mc.alertText.text = "I won!!!";
		winner = 2;
		return;
	}
	if (boardcheck() == 9) {

		alertOK_mc.visible = true;
		alertOK_mc.alertText.text = "It's a draw.";
		return;
	}
}
function updateBoard() {
	// draws the board 
	var i: int;
	var j: int;
	for (i = 0; i < 3; i++) {
		for (j = 0; j < 3; j++) {
			var item: String;
			if (board[i][j] == "O") {
				this["rc" + i + j + "_mc"].gotoAndStop(3);
			}
		}
	}
}
function heuristic1Value(theBoard: Array): int {
	return 3 * XAndOs(theBoard, 2, 0) + XAndOs(theBoard, 1, 0) - 3 * XAndOs(theBoard, 0, 2) - XAndOs(theBoard, 0, 1);
}
function XAndOs(array: Array, Xs: int, Os: int): int {
	var result: int = 0; // the number of occurences of rows, columns and diagonals which have the specified number of x's and o's
	var i: int;
	var j: int;
	// for rows
	var numX: int = 0; //reset
	var numO: int = 0;
	for (i = 0; i < array.length; i++) {
		numX = 0; //reset
		numO = 0;
		for (j = 0; j < array.length; j++) {
			if (array[i][j] == "X") {
				numX++;
			} else if (array[i][j] == "O") {
				numO++;
			}
		}
		if (numX == Xs && numO == Os) {
			result++;
			//trace("Found a matching row!");
		}
	}
	// for columns
	for (j = 0; j < array.length; j++) {
		numX = 0; //reset
		numO = 0;
		for (i = 0; i < array.length; i++) {
			if (array[i][j] == "X") {
				numX++;
			} else if (array[i][j] == "O") {
				numO++;
			}
		}
		if (numX == Xs && numO == Os) {
			result++;
			//trace("Found a matching column!");
		}
	}
	// top left, bottom right diagonal
	numX = 0; //reset
	numO = 0;
	for (i = 0; i < array.length; i++) {
		var player: String = array[i][i];
		if (player == "X") {
			numX++;
		} else if (player == "O") {
			numO++;
		}
	}
	if (numX == Xs && numO == Os) {
		result++;
		//trace("Found a matching TLBR diag!");
	}
	// top right, bottom left diagonal
	numX = 0; //reset
	numO = 0;
	for (i = 0; i < array.length; i++) {
		player = array[i][2 - i];
		if (player == "X") {
			numX++;
		} else if (player == "O") {
			numO++;
		}
	}
	if (numX == Xs && numO == Os) {
		result++;
		//trace("Found a matching TRBL diag!");
	}
	return result;
}
function deepCopy(array: Array, rows: int, columns: int): Array {
	var copy: Array = [
		["-", "-", "-"],
		["-", "-", "-"],
		["-", "-", "-"]
	];
	var row: int, column: int;
	for (row = 0; row < rows; row++) {
		for (column = 0; column < columns; column++) {
			copy[row][column] = array[row][column];
		}
	}
	return copy;
}
function allMoves(): Array { // haven't seen if this works yet
	// assume board is array of "-", "X" and "O" characters/strings
	var allMoves: Array = new Array(9 - boardcheck());
	var row: int, column: int;
	var move: int = 0;
	for (row = 0; row < 3; row++) {
		for (column = 0; column < 3; column++) {
			if (board[row][column] == "-") {
				currentPotentialBoard = deepCopy(board, 3, 3);
				currentPotentialBoard[row][column] = "O";
				//trace("Move choice: ");
				//trace(currentPotentialBoard);
				allMoves[move] = currentPotentialBoard;
				move++;
			}
		}
	}
	return allMoves;
}
//function generateMoves(board: Array): Array { 
//	// assume board is array of "-", "X" and "O" characters/strings
//	var row: int, column: int;
//	for (row = 0; row < 3; row++) {
//		for (column = 0; column < 3; column++) {
//			if (board[row][column] == "-") {
//				currentPotentialBoard = deepCopy(board, 3, 3);
//				currentPotentialBoard[row][column] = "O";
//				trace("Move choice: ");
//				trace(currentPotentialBoard);
//			}
//		}
//	}
//	return currentPotentialBoard;
//}
function cycle_hints(event: MouseEvent): void {
	helpClicks++;
	if (helpClicks == 1) {
		info_field.output.text = "Click the board to make your move";
	} else if (helpClicks == 2) {
		info_field.output.text = "Click the brain to switch to an intelligent opponent";
	} else if (helpClicks == 3) {
		info_field.output.text = "Click NewGame to reset the game";
	}

	if (helpClicks == totalHints) {
		helpClicks = 0;
	}
}
function playRandomly(): void {
	//Computer chooses a random free tile
	var computerrow: int, computercolumn: int;
	var tilename: String;
	var done: int = 0;
	while (done == 0) {
		computerrow = randomRangeInteger(0, 2);
		computercolumn = randomRangeInteger(0, 2);
		if (board[computerrow][computercolumn] == "-") {
			board[computerrow][computercolumn] = "O";
			tilename = "rc" + String(computerrow) + String(computercolumn) + "_mc";
			this[tilename].gotoAndStop(3);
			done = 1;
		}
	}
}
function checkWinner(): int {
	// 1 = user, 2 = computer
	var row: int, column: int;
	var you: int, computer: int;
	var player: String;
	var index: int;
	// row check
	for (row = 0; row < 3; row++) {
		you = 0;
		computer = 0;
		for (column = 0; column < 3; column++) {
			player = board[row][column];
			switch (player) {
				case "X":
					you++;
					break;
				case "O":
					computer++;
					break;
			}
		}
		if (you == 3) {
			return 1;
		} else if (computer == 3) {
			return 2;
		}
	}
	// column check
	for (column = 0; column < 3; column++) {
		you = 0;
		computer = 0;
		for (row = 0; row < 3; row++) {
			player = board[row][column];
			switch (player) {
				case "X":
					you++;
					break;
				case "O":
					computer++;
					break;
			}
		}
		if (you == 3) {
			return 1;
		}
		if (computer == 3) {
			return 2;
		}
	}
	// check diagonal 1
	you = 0;
	computer = 0;
	for (index = 0; index < 3; index++) {
		player = board[index][index];
		switch (player) {
			case "X":
				you++;
				break;
			case "O":
				computer++;
				break;
		}
	}

	if (you == 3) {
		return 1;
	}
	if (computer == 3) {
		return 2;
	}
	// check diagonal 2
	you = 0;
	computer = 0;
	for (index = 0; index < 3; index++) {
		player = board[index][2 - index];
		switch (player) {
			case "X":
				you++;
				break;
			case "O":
				computer++;
				break;
		}
	}

	if (you == 3) {
		return 1;
	}
	if (computer == 3) {
		return 2;
	}
	return 0; // no winner found
}
function boardcheck(): int {
	// returns the number of used cells
	var row: int, column: int;
	var sum: int = 0;
	for (row = 0; row < 3; row++) {
		for (column = 0; column < 3; column++) {
			if (board[row][column] != "-") {
				sum++;
			}
		}
	}
	return sum;
}
function randomRangeInteger(min: int, max: int): int {
	// returns a random int between the two extremes
	var randomNum: int = Math.floor(Math.random() * (max - min + 1)) + min;
	return randomNum;
}
function alertOK_acknowledged(event: MouseEvent) {
	alertOK_mc.visible = false;
}
function change_clever(event: MouseEvent) {
	if (clever_mc.currentFrame == 1) {
		clever_mc.gotoAndStop(2);
	} else {
		clever_mc.gotoAndStop(1);
	}
}
function choose_this_tile(event: MouseEvent) {
	var clickedtilename: String = event.target.name;
	var myrow: int, mycolumn: int;
	if (this[clickedtilename].currentFrame == 1) {
		if ((winner > 0) || (boardcheck() == 9)) {
			// gameover because there is a winner and/or all tiles are filled
			alertOK_mc.visible = true;
			alertOK_mc.alertText.text = "Game over! Click the NewGame button to start again.";
			return;
		} else {
			// get row and column from click event
			myrow = Number(clickedtilename.substr(2, 1));
			mycolumn = Number(clickedtilename.substr(3, 1));
			// note that a human has played
			board[myrow][mycolumn] = "X";
			// show that a human has played
			this[clickedtilename].gotoAndStop(2);
			if (checkWinner() == 1) {
				alertOK_mc.visible = true;
				alertOK_mc.alertText.text = "Congratulations, you won! Click NewGame to play again";
				winner = 1;
				return;
			}
			// if clever play is selected then respond cleverly
			if (clever_mc.currentFrame == 1) {
				if (boardcheck() < 9) {
					playIntelligent();
				}
			} else {
				if (boardcheck() < 9) {
					playRandomly();
				}
			}
			if (checkWinner() == 2) {
				alertOK_mc.visible = true;
				alertOK_mc.alertText.text = "I won!!!";
				winner = 2;
			} else {
				if (boardcheck() == 9) {
					alertOK_mc.visible = true;
					alertOK_mc.alertText.text = "Game over! Click NewGame to start again.";
					return
				}
			}
		}
	}
}
function newgame(event: MouseEvent) {
	var row: int, column: int;
	var tilename: String;
	board = [
		["-", "-", "-"],
		["-", "-", "-"],
		["-", "-", "-"]
	];
	// - = free, X = human player, 0 = computer
	winner = 0;
	for (row = 0; row < 3; row++) {
		for (column = 0; column < 3; column++) {
			tilename = "rc" + String(row) + String(column) + "_mc";
			this[tilename].gotoAndStop(1);
			info_field.text = "Game started.";
		}
	}
}
function alertOK_off(even: MouseEvent) {
	alertOK_mc.visible = false;
}
