//
//  GameView.m
//  Mancala
//
//  Created by Alessandro Vinciguerra on 2018/07/03.
//      <alesvinciguerra@gmail.com>
//Copyright (C) 2018 Arc676/Alessandro Vinciguerra

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation (version 3) with the exception that
//linking Apple libraries is allowed to the extent to which this is necessary
//for compilation

//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.
//See README and LICENSE for more details

#import "GameView.h"

@implementation GameView

- (void)awakeFromNib {
	self.pebbleCount = 4;
	self.fastMode = NO;
	self.gameInProgress = NO;
	self._2player = NO;

	self.currentPlayer = 1;
	self.endState = NOT_OVER;

	self.pebblesUp = NSMakeRect(50, 160, 100, 50);
	self.pebblesDown = NSMakeRect(50, 50, 100, 50);

	self.pUp = [NSImage imageNamed:@"Up.png"];
	self.pDown = [NSImage imageNamed:@"Down.png"];

	self.fmButton = NSMakeRect(210, 100, 100, 100);
	self._2pButton = NSMakeRect(320, 100, 100, 100);

	self.gameStart = NSMakeRect(320, 40, 100, 50);
}

- (void)drawRect:(NSRect)rect {
	[[NSColor whiteColor] set];
	NSRectFill(rect);
	if (self.gameInProgress) {
		int x = 25, dx = 60, y = 20;
		for (int i = 0; i < 14; i++) {
			[[NSColor lightGrayColor] set];
			int yi = y, h = 50;
			x += dx;
			if (i == MANCALA_GOAL1 || i == MANCALA_GOAL2) {
				yi = 20;
				h = 110;
				dx = -dx;
				y += 60;
			}
			NSRect pocket = NSMakeRect(x, yi, 50, h);
			NSRectFill(pocket);
			[[NSString stringWithFormat:@"%d", self.board->board[i]] drawAtPoint:NSMakePoint(x, yi) withAttributes:nil];
		}
		NSPoint point = NSMakePoint(30, 250);
		switch (self.endState & ~FAST_WIN) {
			case P1_WINS | P2_WINS:
				[@"Tie!" drawAtPoint:point withAttributes:nil];
				break;
			case P1_WINS:
				[@"Player 1 wins!" drawAtPoint:point withAttributes:nil];
				break;
			case P2_WINS:
				[@"Player 2 wins!" drawAtPoint:point withAttributes:nil];
				break;
			case NOT_OVER:
				[[NSString stringWithFormat:@"Player %d's turn", self.currentPlayer] drawAtPoint:point withAttributes:nil];
				break;
			default:
				break;
		}
	} else {
		[[NSColor grayColor] set];
		NSRectFill(self.gameStart);

		[self.pUp drawInRect:self.pebblesUp];
		[self.pDown drawInRect:self.pebblesDown];
		[[NSString stringWithFormat:@"%d", self.pebbleCount] drawAtPoint:NSMakePoint(75, 105) withAttributes:nil];

		if (self.fastMode) {
			[[NSColor greenColor] set];
		} else {
			[[NSColor redColor] set];
		}
		NSRectFill(self.fmButton);

		if (self._2player) {
			[[NSColor greenColor] set];
		} else {
			[[NSColor redColor] set];
		}
		NSRectFill(self._2pButton);
	}
}

- (void)mouseUp:(NSEvent *)event {
	if (self.endState != NOT_OVER) {
		self.gameInProgress = NO;
		return;
	}
	if (self.gameInProgress) {
		NSPoint loc = event.locationInWindow;
		if (loc.x >= 85 && loc.x <= 445 && loc.y >= 20 && loc.y <= 130) {
			int pocket = (loc.x - 85) / 60;
			if (loc.y >= 80) {
				pocket = getOppositePocket(pocket);
			}
			// check that the chosen pocket belongs to the correct player
			if ((pocket > MANCALA_GOAL1) == (self.currentPlayer == 1)) {
				return;
			}
			int result = movePocket(self.board,
									pocket,
									self.currentPlayer == 1 ? MANCALA_GOAL1 : MANCALA_GOAL2);
			if (result == MOVE_EXTRA_TURN) {
				[self setNeedsDisplay:YES];
				return;
			}
			if (self.currentPlayer == 1 && self._2player) {
				self.currentPlayer = 2;
			} else if (self.currentPlayer == 2) {
				self.currentPlayer = 1;
			} else {
				[self performComputerMove];
			}
			self.endState = gameIsOver(self.board);
		}
	} else {
		if (NSPointInRect(event.locationInWindow, self.pebblesUp)) {
			self.pebbleCount++;
		} else if (self.pebbleCount > 1 && NSPointInRect(event.locationInWindow, self.pebblesDown)) {
			self.pebbleCount--;
		} else if (NSPointInRect(event.locationInWindow, self.fmButton)) {
			self.fastMode = !self.fastMode;
		} else if (NSPointInRect(event.locationInWindow, self._2pButton)) {
			self._2player = !self._2player;
		} else if (NSPointInRect(event.locationInWindow, self.gameStart)) {
			[self startGame];
		}
	}
	[self setNeedsDisplay:YES];
}

- (void)startGame {
	if (self.board) {
		free(self.board);
	}
	self.board = (MancalaBoard*)malloc(sizeof(MancalaBoard));
	setupBoard(self.board, self.pebbleCount, self.fastMode);
	self.gameInProgress = YES;
}

- (void)performComputerMove {
	ComputerMoveData* data = (ComputerMoveData*)malloc(sizeof(ComputerMoveData));
	computerMove(self.board, data);
	if (data->result == MOVE_FAILED) {
		return;
	}
	if (data->result == MOVE_EXTRA_TURN) {
		[self performComputerMove];
	}
	free(data);
}

@end
