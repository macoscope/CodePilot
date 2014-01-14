//
//  MCStringScoring.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 3/27/10.
//  Copyright 2010 Macoscope. All rights reserved.
//


struct MCStringScoringMatchTreeNode {
  struct MCStringScoringMatchTreeNode* parentNode;
  int matchIndex;
  unsigned int nextNodesCount;
  struct MCStringScoringMatchTreeNode** nextNodes;
};

float MCStringScoring_scoreForCombination(int *combination, int combinationLength, int fullStringLength);
float MCStringScoring_scoreStringForQuery(const char *scoredString, const char *query, int *indexesOfMatchedChars);
float MCStringScoring_findBestMatch(int **matchIndexes, int queryLength, int valueLength, int* scoredIndexes);
float MCStringScoring_scoreStringForQueryNEW(const char *scoredString, const char *query, int *indexesOfMatchedChars);
float MCStringScoring_findBestMatchNEW(int **matchIndexes, int queryLength, int valueLength, int* scoredIndexes);
void MCStringScoring_printMatches(int **matchIndexes, int queryLength, int valueLength);
void MCStringScoring_printMatchTree(struct MCStringScoringMatchTreeNode *parentNode, int currentLevel);
unsigned int MCStringScoring_buildMatchTree(int **matchIndexes, struct MCStringScoringMatchTreeNode *parentNode, int currentLevel, int maxLevel, int maxLevelElements);
void MCStringScoring_freeMatchTree(struct MCStringScoringMatchTreeNode *rootNode);
void MCStringScoring_combinationsFromTree(struct MCStringScoringMatchTreeNode *parentNode, int currentLevel, int maxLevel, int elementsCount, int **combinations, int *currentCombinationIndex);

struct MCStringScoringMatchTreeNode* newMatchTreeNode();