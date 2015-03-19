//
//  GameScene.m
//  ChineseChess
//
//  Created by gurdjieff on 12-12-28.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "SimpleAudioEngine.h"


int side;
unsigned char board[256];
unsigned char piece[48];
char FenString[128];
typedef struct {
	unsigned char  from, to;
	unsigned char  capture;
}move;
move MoveStack[128];
move UserMoveArray[128];
int UserMoverNum;
int StackTop;
move BestMove;
int ply;
int MaxDepth;
const int MaxValue = 5000;



void ClearBoard();
void OutputBoard();
void OutputPiece();
char IntToChar(int a);
int CharToSubscript(char ch);

void AddPiece(int pos, int pc);
void StringToArray(const char *FenStr);
void ArrayToString();


int SaveMove(unsigned char from, unsigned char to,move * mv);
int GenAllMove(move * MoveArray);
void OutputMove();
int Check(int lSide);
int HasLegalMove();



short Eval(void);
int IntToSubscript(int a);


int MinMaxSearch(int depth);
int MaxSearch(int depth);
int MinSearch(int depth);


int AlphaBetaSearch(int depth, int alpha, int beta);
bool MakeMove(move m);
void UnMakeMove();
void ChangeSide();



//const short PieceValue[8]={10000,20,20,40,90,45,10,0};
const short PieceValue[48] = {
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	1000,20,20,20,20,40,40,90,90,45,45,10,10,10,10,10,
	1000,20,20,20,20,40,40,90,90,45,45,10,10,10,10,10
};
//
//const short PieceValue[48] = {
//	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//	1000,20,20,20,20,40,40,90,90,45,45,10,10,10,10,10,
//	1000,20,20,20,20,40,40,90,90,45,45,10,10,10,10,10
//};

short KingDir[8] ={-0x10, -0x01, +0x01, +0x10, 0, 0, 0, 0};
short kingpalace[9] = {54,55,56,70,71,72,86,87,88};

short AdvisorDir[8]={-0x11, -0x0f, +0x0f, +0x11, 0, 0, 0, 0};

short BishopDir[8] ={-0x22, -0x1e, +0x1e, +0x22, 0, 0, 0, 0};
short BishopCheck[8] = {-0x11,-0x0f,+0x0f,+0x11,0,0,0,0};

short KnightDir[8] ={-0x21, -0x1f, -0x12, -0x0e, +0x0e,	+0x12, +0x1f, +0x21};
short KnightCheck[8] = {-0x10,-0x10,-0x01,+0x01,-0x01,+0x01,+0x10,+0x10};

short RookDir[8] = {-0x01, +0x01, -0x10, +0x10, 0, 0, 0, 0};
short CannonDir[8] ={-0x01, +0x01, -0x10, +0x10, 0, 0, 0, 0};
short PawnDir[2][8]={
    {-0x01, +0x01, -0x10, 0, 0, 0, 0, 0},
    {-0x01, +0x01, +0x10, 0, 0, 0, 0, 0}
};

unsigned char LegalPosition[2][256] ={
	{
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 9, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0, 0, 0,
		0, 0, 0, 9, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0, 0, 0,
		0, 0, 0, 9, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0, 0, 0,
		0, 0, 0, 9, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0, 0, 0,
		0, 0, 0, 9, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0, 0, 0,
		0, 0, 0, 9, 1,25, 1, 9, 1,25, 1, 9, 0, 0, 0, 0,
		0, 0, 0, 9, 1, 9, 1, 9, 1, 9, 1, 9, 0, 0, 0, 0,
		0, 0, 0, 17, 1, 1, 7, 19, 7, 1, 1, 17, 0, 0, 0, 0,
		0, 0, 0, 1, 1, 1, 3, 7, 3, 1, 1, 1, 0, 0, 0, 0,
		0, 0, 0, 1, 1, 17, 7, 3, 7, 17, 1, 1, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	},
	{
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 1, 1, 17, 7, 3, 7, 17, 1, 1, 0, 0, 0, 0,
		0, 0, 0, 1, 1, 1, 3, 7, 3, 1, 1, 1, 0, 0, 0, 0,
		0, 0, 0, 17, 1, 1, 7, 19, 7, 1, 1, 17, 0, 0, 0, 0,
		0, 0, 0, 9, 1, 9, 1, 9, 1, 9, 1, 9, 0, 0, 0, 0,
		0, 0, 0, 9, 1,25, 1, 9, 1,25, 1, 9, 0, 0, 0, 0,
		0, 0, 0, 9, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0, 0, 0,
		0, 0, 0, 9, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0, 0, 0,
		0, 0, 0, 9, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0, 0, 0,
		0, 0, 0, 9, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0, 0, 0,
		0, 0, 0, 9, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	}
};

unsigned char PositionMask[7] = {2, 4, 16, 1, 1, 1, 8};
const char PieceNumToType[48] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 6, 6, 6,
    0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 6, 6, 6
};

const unsigned char PositionValues[2][7][256] =
{
	{
		{
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  1,  1,  1,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0, 10, 10, 10,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0, 15, 20, 15,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		},
		{
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0, 30,  0, 30,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0, 22,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0, 30,  0, 30,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		},
		{
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0, 25,  0,  0,  0, 25,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0, 20,  0,  0,  0, 35,  0,  0,  0, 20,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0, 30,  0,  0,  0, 30,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		},
		{
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0, 70, 80, 90, 80, 70, 80, 90, 80, 70,  0,  0,  0,  0,
			0,  0,  0, 80,110,125, 90, 70, 90,125,110, 80,  0,  0,  0,  0,
			0,  0,  0, 90,100,120,125,120,125,120,100, 90,  0,  0,  0,  0,
			0,  0,  0, 90,100,120,130,110,130,120,100, 90,  0,  0,  0,  0,
			0,  0,  0, 90,110,110,120,100,120,110,110, 90,  0,  0,  0,  0,
			0,  0,  0, 90,100,100,110,100,110,100,100, 90,  0,  0,  0,  0,
			0,  0,  0, 80, 90,100,100, 90,100,100, 90, 80,  0,  0,  0,  0,
			0,  0,  0, 80, 80, 90, 90, 80, 90, 90, 80, 80,  0,  0,  0,  0,
			0,  0,  0, 70, 75, 75, 70, 50, 70, 75, 75, 70,  0,  0,  0,  0,
			0,  0,  0, 60, 70, 75, 70, 60, 70, 75, 70, 60,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		},
        
		{
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,160,170,160,150,150,150,160,170,160,  0,  0,  0,  0,
			0,  0,  0,170,180,170,190,250,190,170,180,170,  0,  0,  0,  0,
			0,  0,  0,170,190,200,220,240,220,200,190,170,  0,  0,  0,  0,
			0,  0,  0,180,220,210,240,250,240,210,220,180,  0,  0,  0,  0,
			0,  0,  0,180,220,210,240,250,240,210,220,180,  0,  0,  0,  0,
			0,  0,  0,180,220,210,240,250,240,210,220,180,  0,  0,  0,  0,
			0,  0,  0,170,190,180,220,240,220,200,190,170,  0,  0,  0,  0,
			0,  0,  0,170,180,170,170,160,170,170,180,170,  0,  0,  0,  0,
			0,  0,  0,160,170,160,160,150,160,160,170,160,  0,  0,  0,  0,
			0,  0,  0,150,160,150,160,150,160,150,160,150,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		},
		{
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,125,130,100, 70, 60, 70,100,130,125,  0,  0,  0,  0,
			0,  0,  0,110,125,100, 70, 60, 70,100,125,110,  0,  0,  0,  0,
			0,  0,  0,100,120, 90, 80, 80, 80, 90,120,100,  0,  0,  0,  0,
			0,  0,  0, 90,110, 90,110,130,110, 90,110, 90,  0,  0,  0,  0,
			0,  0,  0, 90,110, 90,110,130,110, 90,110, 90,  0,  0,  0,  0,
			0,  0,  0, 90,100, 90,110,130,110, 90,100, 90,  0,  0,  0,  0,
			0,  0,  0, 90,100, 90, 90,110, 90, 90,100, 90,  0,  0,  0,  0,
			0,  0,  0, 90,100, 80, 80, 70, 80, 80,100, 90,  0,  0,  0,  0,
			0,  0,  0, 80, 90, 80, 70, 65, 70, 80, 90, 80,  0,  0,  0,  0,
			0,  0,  0, 80, 90, 80, 70, 60, 70, 80, 90, 80,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		},
		{
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0, 10, 10, 10, 20, 25, 20, 10, 10, 10,  0,  0,  0,  0,
			0,  0,  0, 25, 30, 40, 50, 60, 50, 40, 30, 25,  0,  0,  0,  0,
			0,  0,  0, 25, 30, 30, 40, 40, 40, 30, 30, 25,  0,  0,  0,  0,
			0,  0,  0, 20, 25, 25, 30, 30, 30, 25, 25, 20,  0,  0,  0,  0,
			0,  0,  0, 15, 20, 20, 20, 20, 20, 20, 20, 15,  0,  0,  0,  0,
			0,  0,  0, 10,  0, 15,  0, 15,  0, 15,  0, 10,  0,  0,  0,  0,
			0,  0,  0, 10,  0, 10,  0, 15,  0, 10,  0, 10,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		}
	},
	{
		{
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0, 15, 20, 15,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0, 10, 10, 10,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  1,  1,  1,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		},
		{
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0, 30,  0, 30,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0, 22,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0, 30,  0, 30,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		},
		{
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0, 30,  0,  0,  0, 30,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0, 20,  0,  0,  0, 35,  0,  0,  0, 20,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0, 25,  0,  0,  0, 25,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		},
		{
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0, 60, 70, 75, 70, 60, 70, 75, 70, 60,  0,  0,  0,  0,
			0,  0,  0, 70, 75, 75, 70, 50, 70, 75, 75, 70,  0,  0,  0,  0,
			0,  0,  0, 80, 80, 90, 90, 80, 90, 90, 80, 80,  0,  0,  0,  0,
			0,  0,  0, 80, 90,100,100, 90,100,100, 90, 80,  0,  0,  0,  0,
			0,  0,  0, 90,100,100,110,100,110,100,100, 90,  0,  0,  0,  0,
			0,  0,  0, 90,110,110,120,100,120,110,110, 90,  0,  0,  0,  0,
			0,  0,  0, 90,100,120,130,110,130,120,100, 90,  0,  0,  0,  0,
			0,  0,  0, 90,100,120,125,120,125,120,100, 90,  0,  0,  0,  0,
			0,  0,  0, 80,110,125, 90, 70, 90,125,110, 80,  0,  0,  0,  0,
			0,  0,  0, 70, 80, 90, 80, 70, 80, 90, 80, 70,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		},
		{
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,150,160,150,160,150,160,150,160,150,  0,  0,  0,  0,
			0,  0,  0,160,170,160,160,150,160,160,170,160,  0,  0,  0,  0,
			0,  0,  0,170,180,170,170,160,170,170,180,170,  0,  0,  0,  0,
			0,  0,  0,170,190,200,220,240,220,180,190,170,  0,  0,  0,  0,
			0,  0,  0,180,220,210,240,250,240,210,220,180,  0,  0,  0,  0,
			0,  0,  0,180,220,210,240,250,240,210,220,180,  0,  0,  0,  0,
			0,  0,  0,180,220,210,240,250,240,210,220,180,  0,  0,  0,  0,
			0,  0,  0,170,190,200,220,240,220,200,190,170,  0,  0,  0,  0,
			0,  0,  0,170,180,170,190,250,190,170,180,170,  0,  0,  0,  0,
			0,  0,  0,160,170,160,150,150,150,160,170,160,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		},
		{
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0, 80, 90, 80, 70, 60, 70, 80, 90, 80,  0,  0,  0,  0,
			0,  0,  0, 80, 90, 80, 70, 65, 70, 80, 90, 80,  0,  0,  0,  0,
			0,  0,  0, 90,100, 80, 80, 70, 80, 80,100, 90,  0,  0,  0,  0,
			0,  0,  0, 90,100, 90, 90,110, 90, 90,100, 90,  0,  0,  0,  0,
			0,  0,  0, 90,100, 90,110,130,110, 90,100, 90,  0,  0,  0,  0,
			0,  0,  0, 90,110, 90,110,130,110, 90,110, 90,  0,  0,  0,  0,
			0,  0,  0, 90,110, 90,110,130,110, 90,110, 90,  0,  0,  0,  0,
			0,  0,  0,100,120, 90, 80, 80, 80, 90,120,100,  0,  0,  0,  0,
			0,  0,  0,110,125,100, 70, 60, 70,100,125,110,  0,  0,  0,  0,
			0,  0,  0,125,130,100, 70, 60, 70,100,130,125,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		},
		{
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0, 10,  0, 10,  0, 15,  0, 10,  0, 10,  0,  0,  0,  0,
			0,  0,  0, 10,  0, 15,  0, 15,  0, 15,  0, 10,  0,  0,  0,  0,
			0,  0,  0, 15, 20, 20, 20, 20, 20, 20, 20, 15,  0,  0,  0,  0,
			0,  0,  0, 20, 25, 25, 30, 30, 30, 25, 25, 20,  0,  0,  0,  0,
			0,  0,  0, 25, 30, 30, 40, 40, 40, 30, 30, 25,  0,  0,  0,  0,
			0,  0,  0, 25, 30, 40, 50, 60, 50, 40, 30, 25,  0,  0,  0,  0,
			0,  0,  0, 10, 10, 10, 20, 25, 20, 10, 10, 10,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
			0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		}
	}
};

int IntToSubscript(int a)
{
	if(a<16 && a>=48)
		return 7;
	
	if(a >=32)
		a = a-16;
    
	switch(a)
	{
        case 16:	return 0;
        case 17:
        case 18:	return 1;
        case 19:
        case 20:	return 2;
        case 21:
        case 22:	return 3;
        case 23:
        case 24:	return 4;
        case 25:
        case 26:	return 5;
        case 27:
        case 28:
        case 29:
        case 30:
        case 31:	return 6;
        default:	return 7;
	}
}

short Eval(void)
{
	short i;
	short bValue,wValue;
	short fValue[2]={0,0};
	bValue = wValue = 0;
    
    //基本分值。
#if 1
	for(i=16; i<32; i++)
	{
		if(piece[i]>0)
			wValue = wValue + PieceValue[i];
	}
    
	for(i=32; i<48; i++)
	{
		if(piece[i]>0)
			bValue = bValue + PieceValue[i];
	}
#endif
#if 1
    //位置分值。
	for(i=16; i<32; i++)
	{
		if(piece[i]>0)
			wValue = wValue + PositionValues[0][PieceNumToType[i]][piece[i]];
	}
    
	for(i=32; i<48; i++)
	{
		if(piece[i]>0)
			bValue = bValue + PositionValues[1][PieceNumToType[i]][piece[i]];
	}

#endif
   
#if 1
    short j,k,r;
    unsigned char p;
	unsigned char n;
	unsigned char m;
	int SideTag;
	int OverFlag;
    //灵活性分值。
	for(r=0;r<=1;r++)
	{
		SideTag = 16 + 16 * r;
        
		for(k=0; k<4; k++)
		{
            p = piece[SideTag];
			n = p + KingDir[k];
			if(LegalPosition[r][n] & PositionMask[0])
			{
				if( !(board[n] & SideTag))
					fValue[r]+=2;
			}
		}
        
		for(i=1; i<=2; i++)
		{
			p = piece[SideTag + i];
			if(!p)
				continue;
			for(k=0; k<4; k++)
			{
				n = p + AdvisorDir[k];
				if(LegalPosition[r][n] & PositionMask[1])
				{
					if( !(board[n] & SideTag))
						fValue[r]+=2;
				}
			}
		}
        
		for(i=3; i<=4; i++)
		{
			p = piece[SideTag + i];
			if(!p)
				continue;
			for(k=0; k<4; k++)
			{
				n = p + BishopDir[k];
				if(LegalPosition[r][n] & PositionMask[2])
				{
					m = p + BishopCheck[k];
					if(!board[m])
					{
						if( !(board[n] & SideTag))
							fValue[r]+=2;
					}
				}
			}
		}
        
		
		for(i=5; i<=6; i++)
		{
			p = piece[SideTag + i];
			if(!p)
				continue;
			for(k=0; k<8; k++)
			{
				n = p + KnightDir[k];
				if(LegalPosition[r][n] & PositionMask[3])
				{
					m = p + KnightCheck[k];
					if(!board[m])
					{
						if( !(board[n] & SideTag))
							fValue[r]+=5;
					}
				}
			}
		}
        
		
		for(i=7; i<=8; i++)
		{
			p = piece[SideTag + i];
			if(!p)
				continue;
			for(k=0; k<4; k++)
			{
				for(j=1; j<10; j++)
				{
					n = p + j * RookDir[k];
					if(!(LegalPosition[r][n] & PositionMask[4]))
						break;
					if(! board[n] )
					{
						fValue[r]+=4;
					}
					else if ( board[n] & SideTag)
						break;
					else
					{
						fValue[r]+=4;
						break;
					}
				}
			}
		}
        
		for(i=9; i<=10; i++)
		{
			p = piece[SideTag + i];
			if(!p)
				continue;
			for(k=0; k<4; k++)
			{
				OverFlag = 0;
				for(j=1; j<10; j++)
				{
					n = p + j * CannonDir[k];
					if(!(LegalPosition[r][n] & PositionMask[5]))
						break;
					if(! board[n] )
					{
						if(!OverFlag)
							fValue[r]+=3;
					}
					else
					{
						if (!OverFlag)
							OverFlag = 1;
						else
						{
							if(! (board[n] & SideTag))
								fValue[r]+=3;
							break;
						}
					}
				}
			}
		}
        
		
		for(i=11; i<=15; i++)
		{
			p = piece[SideTag + i];
			if(!p)
				continue;
			for(k=0; k<3; k++)
			{
				n = p + PawnDir[r][k];
				if(LegalPosition[r][n] & PositionMask[6])
				{
					if( !(board[n] & SideTag))
						fValue[r]+=2;
				}
			}
		}
	}
#endif

    
    if (side == 0) {
        return fValue[0] - fValue[1] + wValue - bValue;
    } else {
        return fValue[1] - fValue[0] + bValue - wValue;
    }

  	return fValue[0] - fValue[1] + wValue - bValue;
}


char IntToChar(int a)
{
	if(a <32)
	{
		switch(a)
		{
            case 16:	return 'K';
            case 17:
            case 18:	return 'A';
            case 19:
            case 20:	return 'B';
            case 21:
            case 22:	return 'N';
            case 23:
            case 24:	return 'R';
            case 25:
            case 26:	return 'C';
            case 27:
            case 28:
            case 29:
            case 30:
            case 31:	return 'P';
            default:	return 0;
		}
	}
	else
	{
		a = a-16;
		switch(a)
		{
            case 16:	return 'k';
            case 17:
            case 18:	return 'a';
            case 19:
            case 20:	return 'b';
            case 21:
            case 22:	return 'n';
            case 23:
            case 24:	return 'r';
            case 25:
            case 26:	return 'c';
            case 27:
            case 28:
            case 29:
            case 30:
            case 31:	return 'p';
            default:	return 0;
		}
	}
}

void ClearBoard()
{
	int i;
	side = 0;
	for (i = 0; i < 256; i ++)
	{
		board[i] = 0;
	}
	for (i = 0; i < 48; i ++)
	{
		piece[i] = 0;
	}
}

int CharToSubscript(char ch)
{
	switch(ch)
	{
        case 'k':
        case 'K':return 0;
        case 'a':
        case 'A':return 1;
        case 'b':
        case 'B':return 2;
        case 'n':
        case 'N':return 3;
        case 'r':
        case 'R':return 4;
        case 'c':
        case 'C':return 5;
        case 'p':
        case 'P':return 6;
        default:return 7;
	}
}

void AddPiece(int pos, int pc) {
	board[pos] = pc;
	piece[pc] = pos;
}

void StringToArray(const char *FenStr)
{
	int i, j, k;
	int pcWhite[7]={16,17,19,21,23,25,27};
	int pcBlack[7]={32,33,35,37,39,41,43};
	const char *str;
    
	ClearBoard();
	str = FenStr;
	if (*str == '\0')
	{
		return;
	}
    
	i = 3;
	j = 3;
	while (*str != ' ')
	{
		if (*str == '/')
		{
			j = 3;
			i ++;
			if (i > 12)
			{
				break;
			}
		}
		else if (*str >= '1' && *str <= '9')
		{
			for (k = 0; k < (*str - '0'); k ++)
			{
				if (j >= 11)
				{
					break;
				}
				j ++;
			}
		}
		else if (*str >= 'A' && *str <= 'Z')
		{
			if (j <= 11)
			{
				k = CharToSubscript(*str);
				if (k < 7)
				{
					if (pcWhite[k] < 32)
					{
						AddPiece((i<<4)+j,pcWhite[k]);
						pcWhite[k]++;
					}
				}
				j ++;
			}
		}
		else if (*str >= 'a' && *str <= 'z')
		{
			if (j <= 11)
			{
				k = CharToSubscript(*str);
				if (k < 7)
				{
					if (pcBlack[k] < 48)
					{
						AddPiece((i<<4)+j,pcBlack[k]);
						pcBlack[k]++;
					}
				}
				j ++;
			}
		}
		
		str ++;
		if (*str == '\0')
		{
			return;
		}
	}
  	str ++;
    
	if (*str == 'b')
		side = 1;
	else
		side = 0;
}

void ArrayToString()
{
	int i, j, k, pc;
	char *str;
    
	str = FenString;
	for (i = 3; i <= 12; i ++)
	{
		k = 0;
		for (j = 3; j <= 11; j ++)
		{
			pc = board[(i << 4) + j];
			if (pc != 0)
			{
				if (k > 0)
				{
					*str = k + '0';
					str ++;
					k = 0;
				}
				*str = IntToChar(pc);
				str ++;
			}
			else
			{
				k ++;
			}
		}
		if (k > 0)
		{
			*str = k + '0';
			str ++;
		}
		*str = '/';
		str ++;
	}
	str --;
	*str = ' ';
	str ++;
	*str = (side == 0 ? 'w' : 'b');
	str ++;
	*str = '\0';
}

void OutputBoard()
{
	for(int i=1; i<=256; i++)
	{
		printf("%3d",board[i-1]);
		if(i%16==0)
			printf("\n");
	}
}

void OutputPiece()
{
	int i;
	for(i=16;i<32;i++)
		printf("%4d",piece[i]);
	printf("\n");
	for(i=32;i<48;i++)
		printf("%4d",piece[i]);
	printf("\n");
}

int Check(int lSide)
{
	unsigned char wKing,bKing;
	unsigned char p,q;
	int r;
	int SideTag = 32 - lSide * 16;
	int fSide = 1-lSide;
	int i;
	int PosAdd;
    
	wKing = piece[16];
	bKing = piece[32];
	if(!wKing || !bKing)
		return 0;
    r=1;
	if(wKing%16 == bKing%16)
	{
		for(wKing=wKing-16; wKing!=bKing; wKing=wKing-16)
		{
			if(board[wKing])
			{
				r=0;
				break;
			}
		}
		if(r)
			return r;
	}
    
	q = piece[48-SideTag];
    
	int k;
	unsigned char n;
	unsigned char m;
	
	for(i=5;i<=6;i++)
	{
		p = piece[SideTag + i];
		if(!p)
			continue;
		for(k=0; k<8; k++)
		{
			n = p + KnightDir[k];
			if(n!=q)
				continue;
            
			if(LegalPosition[fSide][n] & PositionMask[3])
			{
				m = p + KnightCheck[k];
				if(!board[m])
				{
					return 1;
				}
			}
		}
	}
	
	r=1;
	for(i=7;i<=8;i++)
	{
		p = piece[SideTag + i];
		if(!p)
			continue;
		if(p%16 == q%16)
		{
			PosAdd = (p>q?-16:16);
			for(p=p+PosAdd; p!=q; p = p+PosAdd)
			{
				if(board[p])
				{
					r=0;
					break;
				}
			}
			if(r)
				return r;
		}
		else if(p/16 ==q/16)
		{
			PosAdd = (p>q?-1:1);
			for(p=p+PosAdd; p!=q; p = p+PosAdd)
			{
				if(board[p])
				{
					r=0;
					break;
				}
			}
			if(r)
				return r;
		}
	}
	
	int OverFlag = 0;
	for(i=9;i<=10;i++)
	{
		p = piece[SideTag + i];
		if(!p)
			continue;
		if(p%16 == q%16)
		{
			PosAdd = (p>q?-16:16);
			for(p=p+PosAdd; p!=q; p = p+PosAdd)
			{
				if(board[p])
				{
					if(!OverFlag)
						OverFlag = 1;
					else
					{
						OverFlag = 2;
						break;
					}
				}
			}
			if(OverFlag==1)
				return 1;
		}
		else if(p/16 ==q/16)
		{
			PosAdd = (p>q?-1:1);
			for(p=p+PosAdd; p!=q; p = p+PosAdd)
			{
				if(board[p])
				{
					if(!OverFlag)
						OverFlag = 1;
					else
					{
						OverFlag = 2;
						break;
					}
				}
			}
			if(OverFlag==1)
				return 1;
		}
	}
    
	for(i=11;i<=15;i++)
	{
		p = piece[SideTag + i];
		if(!p)
			continue;
		for(k=0; k<3; k++)
		{
			n = p + PawnDir[fSide][k];
			if((n==q) && (LegalPosition[fSide][n] & PositionMask[6]))
			{
				return 1;
			}
		}
	}
	return 0;
}

int SaveMove(unsigned char from, unsigned char to,move * mv)
{
	unsigned char p;
	
	p = board[to];
	piece[board[from]] = to;
	if(p)
		piece[p]=0;
	board[to] = board[from];
	board[from] = 0;
    
	int r =Check(side);
	board[from] = board[to];
	board[to] = p;
	piece[board[from]] = from;
	if(p)
		piece[p] = to;
    
	if(!r)
	{
		mv->from = from;
		mv->to = to;
		return 1;
	}
	return 0;
}

int GenAllMove(move * MoveArray)
{
	short i,j,k;
	unsigned char p;
	unsigned char n;
	unsigned char m;
	int SideTag;
	int OverFlag;
	move * mvArray = MoveArray;
	SideTag = 16 + 16 * side;
    
    //rook
    for(i=7; i<=8; i++)
	{
		p = piece[SideTag + i];
		if(!p)
			continue;
		for(k=0; k<4; k++)
		{
			for(j=1; j<10; j++)
			{
				n = p + j * RookDir[k];
				if(!(LegalPosition[side][n] & PositionMask[4]))
					break;
				if(! board[n] )
				{
					if(SaveMove(p, n, mvArray))
						mvArray++;
				}
				else if ( board[n] & SideTag)
					break;
				else
				{
					if(SaveMove(p, n, mvArray))
						mvArray++;
					break;
				}
			}
		}
	}
    

    //hourse
    for(i=5; i<=6; i++)
	{
		p = piece[SideTag + i];
		if(!p)
			continue;
		for(k=0; k<8; k++)
		{
			n = p + KnightDir[k];
			if(LegalPosition[side][n] & PositionMask[3])
			{
				m = p + KnightCheck[k];
				if(!board[m])
				{
					if( !(board[n] & SideTag))
						if(SaveMove(p, n, mvArray))
							mvArray++;
				}
			}
		}
	}
    
    //cannon
	for(i=9; i<=10; i++)
	{
		p = piece[SideTag + i];
		if(!p)
			continue;
		for(k=0; k<4; k++)
		{
			OverFlag = 0;
			for(j=1; j<10; j++)
			{
				n = p + j * CannonDir[k];
				if(!(LegalPosition[side][n] & PositionMask[5]))
					break;
				if(! board[n] )					{
					if(!OverFlag)
						if(SaveMove(p, n, mvArray))
							mvArray++;
				}
				else
				{
					if (!OverFlag)
						OverFlag = 1;
					else
					{
						if(! (board[n] & SideTag))
							if(SaveMove(p, n, mvArray))
								mvArray++;
						break;
					}
				}
			}
		}
	}
    
    //paw
    for(i=11; i<=15; i++)
	{
		p = piece[SideTag + i];
		if(!p)
			continue;
		for(k=0; k<3; k++)
		{
			n = p + PawnDir[side][k];
			if(LegalPosition[side][n] & PositionMask[6])
			{
				if( !(board[n] & SideTag))
					if(SaveMove(p, n, mvArray))
						mvArray++;
			}
		}
	}
    
    for(i=1; i<=2; i++)
	{
		p = piece[SideTag + i];
		if(!p)
			continue;
		for(k=0; k<4; k++)
		{
			n = p + AdvisorDir[k];
			if(LegalPosition[side][n] & PositionMask[1])
			{
				if( !(board[n] & SideTag))
					if(SaveMove(p, n, mvArray))
						mvArray++;
			}
		}
	}
    
	for(i=3; i<=4; i++)
	{
		p = piece[SideTag + i];
		if(!p)
			continue;
		for(k=0; k<4; k++)
		{
			n = p + BishopDir[k];
			if(LegalPosition[side][n] & PositionMask[2])
			{
				m = p + BishopCheck[k];
				if(!board[m])					{
					if( !(board[n] & SideTag))
						if(SaveMove(p, n, mvArray))
							mvArray++;
				}
			}
		}
	}

    //king
    for(k=0; k<4; k++)
	{
        p = piece[SideTag];
        if(!p)
            return 0;
		n = p + KingDir[k];
		if(LegalPosition[side][n] & PositionMask[0])
		{
			if( !(board[n] & SideTag))
				if(SaveMove(p, n, mvArray))
					mvArray++;
		}
	}

	return mvArray - MoveArray;
}

int HasLegalMove()
{
	move mvArray[128];
	int num;
	num = GenAllMove(mvArray);
	return num;
}


void OutputMove(move * MoveArray, int MoveNum)
{
	int i;
	for(i=0; i<MoveNum; i++)
	{
		printf("from %3d to %3d\n",MoveArray[i].from,MoveArray[i].to);
	}
	printf("total move number:%d\n",MoveNum);
}

void ChangeSide()
{
	side = 1- side;
}

bool  MakeMove(move m)
{
	unsigned char from, dest, p;
	int SideTag = (side==0 ? 32:16);
    
	from = m.from;
	dest = m.to;
	
	MoveStack[StackTop].from = from;
	MoveStack[StackTop].to = dest;
	MoveStack[StackTop].capture = p = board[dest];
	StackTop++;
    
	if(p>0)
		piece[p] = 0;
	piece[board[from]] = dest;
    
	board[dest] = board[from];
	board[from] = 0;
    
	ply++;
    
	ChangeSide();
	
	return p == SideTag;
}

void UnMakeMove(void)
{
	unsigned char from, dest,p;
	
	StackTop--;
	ply--;
	
	ChangeSide();
    
	from = MoveStack[StackTop].from;
	dest = MoveStack[StackTop].to;
	p = MoveStack[StackTop].capture;
    
	board[from] = board[dest];
	board[dest] = p;
    
	if(p>0)
		piece[p] = dest;
	piece[board[from]] = from;
	
}

void checkOneStepWin(move * MoveArray, int start, int num)
{
    for (int i = start + 1; i < num; i++) {
        move mv = MoveArray[i];
		MakeMove(mv);
        int num = HasLegalMove();
        UnMakeMove();
        if (num == 0) {
            BestMove = mv;
            break;
        }
    }
}

int AlphaBetaSearch(int depth, int alpha, int beta)
{
	int value;
	move MoveArray[128];
	move mv;
	int i;
    
	if(depth ==0)
		return Eval();
	int num = GenAllMove(MoveArray);
  	for(i = 0 ; i<num; i++)
	{
		mv = MoveArray[i];
		MakeMove(mv);
		value = -AlphaBetaSearch(depth -1, -beta, -alpha);
		UnMakeMove();
		if(value >= beta) {
            if(depth == MaxDepth) {
                BestMove = mv;
                checkOneStepWin(MoveArray, i, num);
            }
            return beta;
        }
		if(value > alpha)
		{
            alpha = value;
			if(depth == MaxDepth) {
                BestMove = mv;
            }
		}
	}
	return alpha;
}

int __AlphaBetaSearch(int depth, int alpha, int beta, move repeatMove)
{
	int value;
	move MoveArray[128];
	move mv;
	int i;
    
	if(depth ==0)
		return Eval();
    
	int num = GenAllMove(MoveArray);
	for(i = 0 ; i<num; i++)
	{
		mv = MoveArray[i];
        if (i > 0 && mv.from == repeatMove.from
            && mv.to == repeatMove.to) {
            continue;
        }
		MakeMove(mv);
		value = -AlphaBetaSearch(depth -1, -beta, -alpha);
		UnMakeMove();
		if(value >= beta) {
            if(depth == MaxDepth) {
                BestMove = mv;
                checkOneStepWin(MoveArray, i, num);
            }
            return beta;
        }
		if(value > alpha)
		{
			alpha = value;
			if(depth == MaxDepth)
				BestMove = mv;
		}
	}
	return alpha;
}





@interface GameScene()
-(void)addBackGround;
-(void)addPieces;
-(void)resetPiecesLocation;
-(void)computerBeginRace;


@end
@implementation GameScene
@synthesize level = miLevel;



+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	GameScene *layer = [GameScene node];
	[scene addChild: layer];
	return scene;
}

-(void)initData
{
    StringToArray("rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1");
//    StringToArray("4k4/9/1c5c1/9/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1");
//    StringToArray("rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/9/1C5C1/9/4K4 w - - 0 1");
//    StringToArray("r1bk1ab2/1cN1a1n2/9/P1p1p3R/3R5/9/4P3P/2N1C3B/4A4/4KA3 b - - 0 1");
    

    miLevel = 4;
    screenSize = [[CCDirector sharedDirector] winSize];
    mpBlackSceneAry = [[NSMutableArray alloc] init];
    mpRedSceneAry = [[NSMutableArray alloc] init];
    winSprite = [CCSprite spriteWithFile:@"winSprite.png"];
    winSprite.scale = 0.0;
    CGPoint point = CGPointMake(screenSize.width/2, screenSize.height/2+40);
    winSprite.position = point;
    [self addChild:winSprite z:3 tag:10];
    
    failSprite = [CCSprite spriteWithFile:@"failSprite.png"];
    failSprite.scale = 0.0;
    point = CGPointMake(screenSize.width/2, screenSize.height/2+40);
    failSprite.position = point;
    [self addChild:failSprite z:3 tag:10];

        
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"backmusic.mp3" loop:YES];
//    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bg.mp3" loop:YES];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"win.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"check.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"fail.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"fail1.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"select.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"put.mp3"];
}

-(id)init
{
    if ((self = [super init])) {
        [self initData];
        [self addBackGround];
        [self addPieces];
        [self resetPiecesLocation];
        [self setIsTouchEnabled:YES];
        UserMoverNum = GenAllMove(UserMoveArray);
        [self addMenu];
    }
    return self;
}

-(void)addBackGround
{
    CCSprite * sprite = [CCSprite spriteWithFile:@"bg.png"];
    CGPoint point = CGPointMake(screenSize.width/2, screenSize.height/2);
    sprite.position = point;
    mpChessSprite = [CCSprite spriteWithFile:@"chess.png"];
    mpChessSprite.position = CGPointMake(point.x, point.y + 30);
    [self addChild:sprite z:0 tag:0];
    [self addChild:mpChessSprite z:0 tag:0];
//    CCSprite * footer = [CCSprite spriteWithFile:@"footBack.png"];
//    [self addChild:footer z:0 tag:0];
//    footer.position = CGPointMake(point.x, point.y - 200);
}

-(void)addPieces
{    
    NSArray * ary = [[NSArray alloc] initWithObjects:@"K.png",@"A.png",@"A.png",@"B.png", @"B.png",@"N.png",@"N.png", @"R.png",@"R.png", @"C.png",@"C.png", @"P.png",@"P.png",@"P.png",@"P.png",@"P.png",@"bk.png",@"ba.png",@"ba.png",@"bb.png",@"bb.png",@"bn.png",@"bn.png",@"br.png",@"br.png",@"bc.png",@"bc.png",@"bp.png",@"bp.png",@"bp.png",@"bp.png",@"bp.png", nil];
     
    for (int i = 0; i < 32; i++) {
        CCSprite * pieceBg = [CCSprite spriteWithFile:@"pieceBg.png"];
        CCSprite * piece = [CCSprite spriteWithFile:[ary objectAtIndex:i]];
        piece.tag = 100;
        
        CGSize size = [[pieceBg texture] contentSize];
        piece.position = CGPointMake(size.width/2, size.height/2);
        pieceBg.position = CGPointMake(100, -120+i * 30);
        [pieceBg addChild:piece];
        [self addChild:pieceBg z:1 tag:i+16];
    }
}
-(void)menuItem1Touched
{
    [mpRedSceneAry removeAllObjects];
    [mpBlackSceneAry removeAllObjects];
    failSprite.scale = 0.0;
    winSprite.scale = 0.0;
    StringToArray("rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1");
    for (int i = 16; i < 48; i++) {
        CCSprite * piece = (CCSprite *)[self getChildByTag:i];
        piece.scale = 1.0;
    }
    [self resetPiecesLocation];
}


-(void)__resetPiecesLocation
{
    float width = 310.0/9;
    for (int i = 16; i < 48; i++) {
        int location = piece[i];
        CCSprite * piece = (CCSprite *)[self getChildByTag:i];
        if (location == 0 && piece.scale == 1.0) {
            piece.scale = 0.0;
            continue;
        } else {
            int x = location%16-3;
            int y = 9 - (location/16-3);
            
            CGPoint point = CGPointMake(width/2+x*width+5, width/2+y*width+10+90);
            if (ccpDistance(point, piece.position) < 10) {
                continue;
            }
            [self reorderChild:piece z:2];
            CCMoveTo * move = [CCMoveTo actionWithDuration:1.0 position:point];
            CCCallFuncN* call = [CCCallFuncN actionWithTarget:self selector:@selector(resetFinished)];
            CCSequence* sequence = [CCSequence actions:move, call, nil];
            [piece runAction:sequence];
        }
    }
}



-(void)menuItem2Touched
{
    if ([mpBlackSceneAry count] < 2) {
        return;
    }
        
    NSArray * ary = [[mpBlackSceneAry objectAtIndex:1] objectForKey:@"piece"];
    ClearBoard();
    for (int i = 0; i < 32; i++) {
        [ary objectAtIndex:i];
        AddPiece([[ary objectAtIndex:i] intValue], i+16);
    }
    
    for (int i = 16; i < 48; i++) {
        int location = piece[i];
        CCSprite * piece = (CCSprite *)[self getChildByTag:i];
        if (location != 0) {
            piece.scale = 1.0;
        }
    }
    [mpBlackSceneAry removeObjectAtIndex:0];
    UserMoverNum = GenAllMove(UserMoveArray);
    [self __resetPiecesLocation];
}

-(void)menuItem3Touched
{
    if (side == 0) {
        [self computerBeginRace];
    }
}

-(void)addMenu
{
    CCSprite* normal = [CCSprite spriteWithFile:@"reset.png"];
	CCSprite* selected = [CCSprite spriteWithFile:@"reset.png"];
    CCMenuItemSprite* item1 = [CCMenuItemSprite itemWithNormalSprite:normal selectedSprite:selected target:self selector:@selector(menuItem1Touched)];
    
    CCSprite* normal2 = [CCSprite spriteWithFile:@"backScene.png"];
	CCSprite* selected2 = [CCSprite spriteWithFile:@"backScene.png"];
    CCMenuItemSprite* item2 = [CCMenuItemSprite itemWithNormalSprite:normal2 selectedSprite:selected2 target:self selector:@selector(menuItem2Touched)];
    
    
    CCSprite* normal3 = [CCSprite spriteWithFile:@"remind.png"];
	CCSprite* selected3 = [CCSprite spriteWithFile:@"remind.png"];
    CCMenuItemSprite* item3 = [CCMenuItemSprite itemWithNormalSprite:normal3 selectedSprite:selected3 target:self selector:@selector(menuItem3Touched)];
    
    
    CCMenu* menu = [CCMenu menuWithItems:item1,item2, item3,nil];
	menu.position = CGPointMake(screenSize.width/2, 40);
    [menu alignItemsHorizontallyWithPadding:60];
	[self addChild:menu];
}

-(void)backResetFinished
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"put.mp3"];
}


-(void)resetFinished
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"put.mp3"];
    if (side == 1) {
        self.isTouchEnabled = NO;
        [self computerBeginRace];
    } else {
        UserMoverNum = GenAllMove(UserMoveArray);
        if (UserMoverNum == 0) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"fail1.mp3"];
            CCScaleTo * scaleTo = [CCScaleTo actionWithDuration:1.0 scale:1.0];
            [failSprite runAction:scaleTo];

            NSLog(@"user fail");
            return;
        }
        if (Check(side)) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"check.mp3"];
            NSLog(@"user被照将");
        }
        self.isTouchEnabled = YES;
    }
}

-(void)lossPiece
{
//    [[SimpleAudioEngine sharedEngine] playEffect:@"loss.wav"];
}

-(void)resetPiecesLocation
{
    ArrayToString();
    NSString * str = [NSString stringWithCString:FenString encoding:NSUTF8StringEncoding];
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setValue:str forKey:@"scene"];
    [dic setValue:[NSNumber numberWithChar:BestMove.from] forKey:@"from"];
    [dic setValue:[NSNumber numberWithChar:BestMove.to] forKey:@"to"];
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 32; i++) {
        [array addObject:[NSNumber numberWithInt:piece[i+16]]];
    }
    [dic setValue:array forKey:@"piece"];
    [array release];
    
    
    if (side == 0) {
        [mpBlackSceneAry insertObject:dic atIndex:0];
    } else {
        [mpRedSceneAry insertObject:dic atIndex:0];
    }
    [dic release];

    float width = 310.0/9;
    for (int i = 16; i < 48; i++) {
        int location = piece[i];
        CCSprite * piece = (CCSprite *)[self getChildByTag:i];
        if (location == 0 && piece.scale == 1.0) {
            CCScaleTo * scaleTo = [CCScaleTo actionWithDuration:0.8 scale:0];
            CCCallFuncN* call = [CCCallFuncN actionWithTarget:self selector:@selector(lossPiece)];
            CCSequence* sequence = [CCSequence actions:scaleTo, call, nil];
            [piece runAction:sequence];
            continue;
        } else {
            if (piece.scale != 1.0) {
                continue;
            }
            
            int x = location%16-3;
            int y = 9 - (location/16-3);
            
            CGPoint point = CGPointMake(width/2+x*width+5, width/2+y*width+10+90);
            if (ccpDistance(point, piece.position) < 10) {
                continue;
            }
            
            [self reorderChild:piece z:2];
            CCMoveTo * move = [CCMoveTo actionWithDuration:1.0 position:point];
            CCCallFuncN* call = [CCCallFuncN actionWithTarget:self selector:@selector(resetFinished)];
            CCSequence* sequence = [CCSequence actions:move, call, nil];
            [piece runAction:sequence];
        }
    }
}



-(void)computerBeginRace
{

    NSLog(@"1-------------");
    if (Check(side)) {
        NSLog(@"computer被照将");
    }
    BestMove.from = 0;
    BestMove.to = 0;
    MaxDepth = miLevel;
    StackTop = 0;
    
    if (side == 1
        && [mpBlackSceneAry count] > 6
        && [[[mpBlackSceneAry objectAtIndex:1] objectForKey:@"scene"]
            isEqualToString:[[mpBlackSceneAry objectAtIndex:3] objectForKey:@"scene"]]) {
            move repeatMove;
            repeatMove.from = [[[mpBlackSceneAry objectAtIndex:1] objectForKey:@"from"] charValue];
            repeatMove.to = [[[mpBlackSceneAry objectAtIndex:1] objectForKey:@"to"] charValue];
            __AlphaBetaSearch(MaxDepth, -MaxValue, MaxValue, repeatMove);

    } else {
        AlphaBetaSearch(MaxDepth, -MaxValue, MaxValue);
    }

    if (BestMove.from == 0 && BestMove.to == 0) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"win.wav"];
        CCScaleTo * scaleTo = [CCScaleTo actionWithDuration:1.0 scale:1.0];
        [winSprite runAction:scaleTo];
        [self addMenu];

        NSLog(@"computer fail");
        return;
    }
    
    MakeMove(BestMove);
    NSLog(@"2-------------");

    [self resetPiecesLocation];
//    [spirit removeFromParentAndCleanup:YES];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector] convertToGL:point];
    for (int i = 0; i < 16; i++) {
        CCSprite * redPiece = (CCSprite *)[self getChildByTag:i+16];
        if (redPiece) {
            if ([redPiece getActionByTag:100]) {
                [redPiece stopAllActions];
                redPiece.scale = 1.0;
                NSLog(@"%d", UserMoverNum);

                for (int i = 0; i < UserMoverNum; i++) {
                    float width = 310.0/9;
                    CGPoint point1 = redPiece.position;
                    CGPoint point2 = point;
                    int x1 = (point1.x+width/2 - 5 - width/2)/width;
                    int y1 = (point1.y - 90+width/2 - 10 - width/2)/width;
                    int from = (9-y1+3) * 16 + x1 + 3;
                    
                    int x2 = (point2.x+width/2 - 5 - width/2)/width;
                    int y2 = (point2.y-90+width/2 - 10 - width/2)/width;
                    int to = (9-y2+3) * 16 + x2 + 3;
                    move mv = UserMoveArray[i];
                    if (mv.from == from && mv.to == to) {
                        MakeMove(mv);
                        [redPiece stopAllActions];
                        redPiece.scale = 1.0;
                        [self resetPiecesLocation];
                        break;
                    }
                }
            }
            
            if (redPiece && CGRectContainsPoint([redPiece boundingBox], point)) {
                CCScaleTo* scaleUp = [CCScaleTo actionWithDuration:0.25 scale:1.08f];
                CCScaleTo* scaleDown = [CCScaleTo actionWithDuration:0.25 scale:0.92f];
                
                CCSequence* scaleSequence = [CCSequence actions:scaleUp, scaleDown, nil];
                CCRepeatForever* repeatScale = [CCRepeatForever actionWithAction:scaleSequence];
                repeatScale.tag = 100;
                [redPiece runAction:repeatScale];
                [[SimpleAudioEngine sharedEngine] playEffect:@"select.mp3"];
            }
        }
    }
}


-(void)dealloc
{
    [mpBlackSceneAry release], mpBlackSceneAry = nil;
    [mpRedSceneAry release], mpRedSceneAry = nil;
    [super dealloc];
}

@end
