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

	self.pebblesUp = NSMakeRect(100, 160, 100, 100);
	self.pebblesDown = NSMakeRect(100, 50, 100, 100);

	self.fmButton = NSMakeRect(210, 100, 100, 100);
	self._2pButton = NSMakeRect(320, 100, 100, 100);
}

- (void)drawRect:(NSRect)rect {
	[[NSColor whiteColor] set];
	NSRectFill(rect);
	if (self.gameInProgress) {
	} else {
		[[NSColor grayColor] set];
		NSRectFill(self.pebblesUp);
		NSRectFill(self.pebblesDown);
		[[NSString stringWithFormat:@"%d", self.pebbleCount] drawAtPoint:NSMakePoint(120, 70) withAttributes:nil];

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
	if (self.gameInProgress) {
	} else {
		if (NSPointInRect(event.locationInWindow, self.pebblesUp)) {
			self.pebbleCount++;
		} else if (self.pebbleCount > 1 && NSPointInRect(event.locationInWindow, self.pebblesDown)) {
			self.pebbleCount--;
		} else if (NSPointInRect(event.locationInWindow, self.fmButton)) {
			self.fastMode = !self.fastMode;
		} else if (NSPointInRect(event.locationInWindow, self._2pButton)) {
			self._2player = !self._2player;
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
}

@end
