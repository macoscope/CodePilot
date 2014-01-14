//
//  MCStringScoring.c
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 3/27/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#include "MCStringScoring.h"

#define MAX_COMBINATIONS_COUNT 50000

float MCStringScoring_scoreForCombination(int *combination, int combinationLength, int fullStringLength){
  int index;
  int previousIndexValue = 0;
  float baseScore = 0;
  float spacingSum = 0;
  float coverage = (combinationLength*1.0) / (fullStringLength * 1.0);
  
  for(index = 0; index < combinationLength; index++){
    if(0 != index){
      if(combination[index] <= previousIndexValue) return -1;
      spacingSum += (combination[index] - 1 - previousIndexValue);      
    }
    
    previousIndexValue = combination[index];
  }
  
	if(spacingSum == 0 && combinationLength > 1){
		baseScore += (combinationLength * 2);
	} else {
		baseScore += (combinationLength / spacingSum);
	}
	
	baseScore *= coverage;
	baseScore += (baseScore / (combination[0] + 1.0));
	
	return baseScore;
}

float MCStringScoring_findBestMatch(int **matchIndexes, int queryLength, int valueLength, int* scoredIndexes){
  int index;
  int **combinations = malloc(sizeof(int*)*MAX_COMBINATIONS_COUNT);
  int combinationIndex;
  unsigned int queryCharIndex;
  int currentCombinationsCount = 0;
  int winningIndex;
  float highestScore = -1;
  
  for(queryCharIndex = 0; queryCharIndex < queryLength; queryCharIndex++){
    /* count how many paths we have now to check */
    int optionsCount;
    optionsCount = 0;
    for(index = 0; index < valueLength; index++){
      if(-1 == matchIndexes[queryCharIndex][index]) break;
      optionsCount++;
    }
    
    if(currentCombinationsCount*optionsCount > MAX_COMBINATIONS_COUNT){
      fprintf(stderr, "WARNING: breaking due to close limit of MAX_COMBINATIONS_COUNT == %d would be exceeded with %d combinations\n", MAX_COMBINATIONS_COUNT, currentCombinationsCount*optionsCount);
      //////////////////////
      // int index2, index1;
      // for(index1=0;index1<currentCombinationsCount;index1++){
      //  printf("combination %02d: ", index1);
      //  for(index2 = 0; index2 < queryLength; index2++){
      //    printf("%02d ", combinations[index1][index2]);
      //  }
      //   printf("\n");
      // }
      //////////////////////
      break;
    }
    
    /*
     * if we have some choices already, we need to duplicate them optionsCount times
     * to add current variations to them and their copies
     */
    if(currentCombinationsCount > 0){
      /* copying */      
      if(optionsCount > 1){
        for(combinationIndex = currentCombinationsCount; combinationIndex < currentCombinationsCount * optionsCount; combinationIndex++){
          int srcCombinationIndex = combinationIndex % currentCombinationsCount;
          combinations[combinationIndex] = malloc(sizeof(int)*(queryLength+1));
          memset(combinations[combinationIndex], -1, sizeof(int)*(queryLength+1));
          for(index = 0; index < queryLength; index++){
            if(-1 == combinations[srcCombinationIndex][index]) break;
            combinations[combinationIndex][index] = combinations[srcCombinationIndex][index];
          }
        }        
      }

      /* adding current variations */
      for(index = 0; index < optionsCount; index++){
        for(combinationIndex = 0; combinationIndex < currentCombinationsCount; combinationIndex++){
          combinations[combinationIndex + (index * currentCombinationsCount)][queryCharIndex] = matchIndexes[queryCharIndex][index];
        }       
      }

      currentCombinationsCount *= optionsCount;
    } else {
      /* if we don't - just create the ones we're looking at now */
      for(combinationIndex = 0; combinationIndex < optionsCount; combinationIndex++){
        combinations[combinationIndex] = malloc(sizeof(int)*(queryLength+1));
        memset(combinations[combinationIndex], -1, sizeof(int)*(queryLength+1));
        for(index=0;index<queryLength+1;index++) combinations[combinationIndex][index]=-1;
        combinations[combinationIndex][queryCharIndex] = matchIndexes[queryCharIndex][combinationIndex];
      }
      
      currentCombinationsCount = optionsCount;
    }
  }

  winningIndex = -1;
  highestScore = -1;
  for(combinationIndex = 0; combinationIndex < currentCombinationsCount; combinationIndex++){
    float currentScore = MCStringScoring_scoreForCombination(combinations[combinationIndex], queryLength, valueLength);
    /* int index2;
    
    printf("combination %02d: ", combinationIndex);
    for(index2 = 0; index2 < queryLength; index2++){
      printf("%02d ", combinations[combinationIndex][index2]);
    }
    printf(" => %f\n", currentScore); */
    
    if(currentScore > highestScore){
      highestScore = currentScore;
      winningIndex = combinationIndex;
    }
  }
  
  if(-1 != winningIndex){
    for(index = 0; index < queryLength; index++){
      scoredIndexes[index] = combinations[winningIndex][index];
    }
  }

  for(combinationIndex = 0; combinationIndex < currentCombinationsCount; combinationIndex++){
    free(combinations[combinationIndex]);
  }
  
  free(combinations);
  
  return highestScore;
}

void MCStringScoring_printMatches(int **matchIndexes, int queryLength, int valueLength){
  unsigned int queryCharIndex;
  unsigned int matchIndex;

  printf("Printing matches:\n");
  for(queryCharIndex = 0; queryCharIndex < queryLength; queryCharIndex++){
    for(matchIndex = 0; matchIndex < valueLength; matchIndex++){
      if(-1 == matchIndexes[queryCharIndex][matchIndex]) break;
      printf("%d ", matchIndexes[queryCharIndex][matchIndex]);
    }
    printf("\n");
  }
}

float MCStringScoring_scoreStringForQuery(const char *scoredString, const char *query, int *indexesOfMatchedChars) {
  unsigned short index = 0;
  float finalScore = -1.0;

  /*
   * TODO: lowercasing
   */

  int queryIndex = 0;
  int valueIndex = 0;
  unsigned short wordMatches = 1;

  size_t valueLength;
  size_t queryLength;

  /* index of this array corresponds with
   * the char in query string. value is an array
   * of indexes where this char was found in the string
   */
  int **queryCharMatchIndexes;

  valueLength = strlen(scoredString);
  queryLength = strlen(query);

  queryCharMatchIndexes = malloc(sizeof(int*)*queryLength);
  for(index = 0; index < queryLength; index++){
    queryCharMatchIndexes[index] = malloc(sizeof(int*)*(valueLength+1));
    memset(queryCharMatchIndexes[index], -1, sizeof(int*)*(valueLength+1));
  }

  for(valueIndex = 0; valueIndex < valueLength; valueIndex++){
    unsigned char valueChar = scoredString[valueIndex];
   
    for(queryIndex = 0; queryIndex < queryLength; queryIndex++){
      if(valueChar == query[queryIndex] || 	(islower(query[queryIndex]) && toupper(query[queryIndex]) == valueChar)){
        int matchIndex = 0;
        int tmpIndex;
        int indexIsViable = 0;
        
        /* check if the index isn't lower than every index from the previous query char */
        if(0 == queryIndex){
          indexIsViable = 1;
        } else {
          for(tmpIndex=0;tmpIndex<valueLength;tmpIndex++){
            int prevIndexValue = queryCharMatchIndexes[queryIndex-1][tmpIndex];
            if(-1 != prevIndexValue && prevIndexValue < valueIndex){
              indexIsViable = 1;
              break;
            }
          }
        }

        if(indexIsViable){
          while(-1 != queryCharMatchIndexes[queryIndex][matchIndex]) {
            matchIndex++;
          }
        
          queryCharMatchIndexes[queryIndex][matchIndex] = valueIndex;
        }
      }
    }
  }
  
  for(queryIndex = 0; queryIndex < queryLength; queryIndex++){
    if(-1 == queryCharMatchIndexes[queryIndex][0]){
      wordMatches = 0;
      break;
    }
  }
  
  if (wordMatches) {        
//    MCStringScoring_printMatches(queryCharMatchIndexes, queryLength, valueLength); /***/
    finalScore = MCStringScoring_findBestMatch(queryCharMatchIndexes, queryLength, valueLength, indexesOfMatchedChars);

/*
    // if(-1.0 != finalScore){
    //   for(queryIndex = 0, valueIndex = 0; valueIndex < valueLength; valueIndex++){
    //     if(valueIndex == indexesOfMatchedChars[queryIndex]){
    //       printf("%c", toupper(scoredString[valueIndex]));        
    //       queryIndex++;
    //     } else {
    //       printf("%c", tolower(scoredString[valueIndex]));
    //     }
    //   }
    }    */
  }

  for(index = 0; index < queryLength; index++){
    free(queryCharMatchIndexes[index]);
  }

  free(queryCharMatchIndexes);  
  
  return finalScore;
}

struct MCStringScoringMatchTreeNode* newMatchTreeNode(void) {
  struct MCStringScoringMatchTreeNode* s = malloc(sizeof(struct MCStringScoringMatchTreeNode));
  memset(s, 0, sizeof(struct MCStringScoringMatchTreeNode));

  s->parentNode = NULL;
  s->nextNodesCount = 0;
  s->matchIndex = -1;
  
  return s;
}

// returns 1 if viable, 0 if not
unsigned int MCStringScoring_buildMatchTree(int **matchIndexes, struct MCStringScoringMatchTreeNode *parentNode, int currentLevel, int maxLevel, int maxLevelElements) {
  int elementIndex;
  int nextNodesCountToAllocate;
  int childNodeIndex;

  nextNodesCountToAllocate = 0;
  for(elementIndex = 0; elementIndex < maxLevelElements; elementIndex++){
    if(-1 == matchIndexes[currentLevel][elementIndex]) break;
    if(matchIndexes[currentLevel][elementIndex] > parentNode->matchIndex){
      nextNodesCountToAllocate++;
    }
  }
  
  parentNode->nextNodesCount = nextNodesCountToAllocate;
  
  if(nextNodesCountToAllocate > 0){
    int index;
    parentNode->nextNodes = malloc(sizeof(struct MCStringScoringMatchTreeNode *)*nextNodesCountToAllocate);
    for(index=0;index<nextNodesCountToAllocate;index++) parentNode->nextNodes[index] = NULL;

    childNodeIndex = 0;
    for(elementIndex = 0; elementIndex < maxLevelElements; elementIndex++){
      if(-1 == matchIndexes[currentLevel][elementIndex]) break;
      if(matchIndexes[currentLevel][elementIndex] > parentNode->matchIndex){
        int viable = 0;
        struct MCStringScoringMatchTreeNode *tmpNode = newMatchTreeNode();
        tmpNode->matchIndex = matchIndexes[currentLevel][elementIndex];
        
        if(currentLevel < maxLevel){
          viable = MCStringScoring_buildMatchTree(matchIndexes, tmpNode, currentLevel+1, maxLevel, maxLevelElements);
        } else {
          // end 
          viable = 1;
        } 
 
        if(viable){
          tmpNode->parentNode = parentNode;
          parentNode->nextNodes[childNodeIndex] = tmpNode;
          childNodeIndex++;    
        } else {
          parentNode->nextNodes[childNodeIndex] = NULL;
          MCStringScoring_freeMatchTree(tmpNode);
        }
      }
    }  
    
    return (childNodeIndex > 0);
  } else {
    return 0;
  }
}

void MCStringScoring_printMatchTree(struct MCStringScoringMatchTreeNode *parentNode, int currentLevel) {
  int childNodeIndex;
  
  for(childNodeIndex = 0; childNodeIndex < parentNode->nextNodesCount; childNodeIndex++){
    int spaceIndex;
    printf("\n");
    for(spaceIndex = 0; spaceIndex < currentLevel; spaceIndex++) printf("  ");
    
    if(NULL != parentNode->nextNodes[childNodeIndex]){
      printf("%02d", parentNode->nextNodes[childNodeIndex]->matchIndex);
      MCStringScoring_printMatchTree(parentNode->nextNodes[childNodeIndex], currentLevel+1);
    }
  }
}

void MCStringScoring_freeMatchTree(struct MCStringScoringMatchTreeNode *parentNode) {
  if(parentNode->nextNodesCount > 0){
    int childNodeIndex;
    for(childNodeIndex = 0; childNodeIndex < parentNode->nextNodesCount; childNodeIndex++){
      if(NULL != parentNode->nextNodes[childNodeIndex]){ // NULLs can happen if we thought we have something viable but this path ended prematurely.
        MCStringScoring_freeMatchTree(parentNode->nextNodes[childNodeIndex]);
      }
    }    

    free(parentNode->nextNodes);
  }
  
  free(parentNode);
}

void MCStringScoring_combinationsFromTree(struct MCStringScoringMatchTreeNode *parentNode, int currentLevel, int maxLevel, int elementsCount, int **combinations, int* currentCombinationIndex) {  
  if(*currentCombinationIndex >= MAX_COMBINATIONS_COUNT){
    fprintf(stderr, "WARNING: breaking due to close limit of MAX_COMBINATIONS_COUNT == %d would be exceeded\n", MAX_COMBINATIONS_COUNT);
    return;
  }

  if(currentLevel < maxLevel){
    int childNodeIndex;
    for(childNodeIndex = 0; childNodeIndex < parentNode->nextNodesCount; childNodeIndex++){
      if(NULL != parentNode->nextNodes[childNodeIndex]){ // NULLs can happen if we thought we have something viable but this path ended prematurely.
        MCStringScoring_combinationsFromTree(parentNode->nextNodes[childNodeIndex], currentLevel+1, maxLevel, elementsCount, combinations, currentCombinationIndex);
      }
    }
  } else {
    if(NULL == combinations[*currentCombinationIndex]){
      int index;
      combinations[*currentCombinationIndex] = malloc(sizeof(int)*elementsCount);
      for(index=0;index<elementsCount;index++) combinations[*currentCombinationIndex][index] = -1;
    }

    struct MCStringScoringMatchTreeNode *currentNode = parentNode;
    int tmpCurrentLevel = currentLevel-1;
    do {
      combinations[*currentCombinationIndex][tmpCurrentLevel] = currentNode->matchIndex;
      currentNode = currentNode->parentNode;
      tmpCurrentLevel--;
    } while(-1 != currentNode->matchIndex);
    *currentCombinationIndex = ++(*currentCombinationIndex);
  }
}

float MCStringScoring_findBestMatchNEW(int **matchIndexes, int queryLength, int valueLength, int* scoredIndexes){
  int index;
  int **combinations = malloc(sizeof(int*)*MAX_COMBINATIONS_COUNT);
  int *combinationIndexPtr = malloc(sizeof(int));
  int combinationIndex;
  int currentCombinationsCount = 0;
  int winningIndex;
  float highestScore = -1;
  
  struct MCStringScoringMatchTreeNode *rootNode;
  
  for(index=0;index<MAX_COMBINATIONS_COUNT;index++) {
    combinations[index] = NULL;
  }
  
  rootNode = newMatchTreeNode();
  MCStringScoring_buildMatchTree(matchIndexes, rootNode, 0, queryLength-1, valueLength);
  
  // printf("TREE:\n");
  // MCStringScoring_printMatchTree(rootNode, 0);
  
  *combinationIndexPtr = 0;
  MCStringScoring_combinationsFromTree(rootNode, 0, queryLength, valueLength, combinations, combinationIndexPtr);
  MCStringScoring_freeMatchTree(rootNode);
  currentCombinationsCount = *combinationIndexPtr;
  
  // printf("COMBINATIONS FOUND: %d\n", currentCombinationsCount);
  // 
  // for(combinationIndex = 0; combinationIndex < currentCombinationsCount; combinationIndex++){
  //   printf("%02d: ", combinationIndex);
  //   for(index2 = 0; index2 < valueLength; index2++){
  //     printf(" %02d", combinations[combinationIndex][index2]);
  //   }
  // 
  //   printf(" ==> %f\n", MCStringScoring_scoreForCombination(combinations[combinationIndex], queryLength, valueLength));
  // }
  
  for(combinationIndex = 0; combinationIndex < currentCombinationsCount; combinationIndex++){
    float currentScore = MCStringScoring_scoreForCombination(combinations[combinationIndex], queryLength, valueLength);
    
    if(currentScore > highestScore){
      highestScore = currentScore;
      winningIndex = combinationIndex;
    }
  }
  
  if(-1 != winningIndex){
    // for purpose of returning to the program to know which letters were chosen as a match
    for(index = 0; index < queryLength; index++){
      scoredIndexes[index] = combinations[winningIndex][index];
    }
  }

  for(combinationIndex = 0; combinationIndex < currentCombinationsCount; combinationIndex++){
    free(combinations[combinationIndex]);
  }
  
  free(combinations);
  free(combinationIndexPtr);
  
  return highestScore;
}


float MCStringScoring_scoreStringForQueryNEW(const char *scoredString, const char *query, int *indexesOfMatchedChars) {
  unsigned short index = 0;
  float finalScore = -1.0;

  /*
   * TODO: lowercasing
   */

  int queryIndex = 0;
  int valueIndex = 0;
  unsigned short wordMatches = 1;

  size_t valueLength;
  size_t queryLength;

  /* index of this array corresponds with
   * the char in query string. value is an array
   * of indexes where this char was found in the string
   */
  int **queryCharMatchIndexes;

  valueLength = strlen(scoredString);
  queryLength = strlen(query);

  queryCharMatchIndexes = malloc(sizeof(int*)*queryLength);
  for(index = 0; index < queryLength; index++){
    queryCharMatchIndexes[index] = malloc(sizeof(int*)*(valueLength+1));
    memset(queryCharMatchIndexes[index], -1, sizeof(int*)*(valueLength+1));
  }

  for(valueIndex = 0; valueIndex < valueLength; valueIndex++){
    unsigned char valueChar = scoredString[valueIndex];
   
    for(queryIndex = 0; queryIndex < queryLength; queryIndex++){
      if(valueChar == query[queryIndex] || 	(islower(query[queryIndex]) && toupper(query[queryIndex]) == valueChar)){
        int matchIndex = 0;
        int tmpIndex;
        int indexIsViable = 0;
        
        /* check if the index isn't lower than every index from the previous query char */
        if(0 == queryIndex){
          indexIsViable = 1;
        } else {
          for(tmpIndex=0;tmpIndex<valueLength;tmpIndex++){
            int prevIndexValue = queryCharMatchIndexes[queryIndex-1][tmpIndex];
            if(-1 != prevIndexValue && prevIndexValue < valueIndex){
              indexIsViable = 1;
              break;
            }
          }
        }

        if(indexIsViable){
          while(-1 != queryCharMatchIndexes[queryIndex][matchIndex]) {
            matchIndex++;
          }
        
          queryCharMatchIndexes[queryIndex][matchIndex] = valueIndex;
        }
      }
    }
  }
  
  for(queryIndex = 0; queryIndex < queryLength; queryIndex++){
    if(-1 == queryCharMatchIndexes[queryIndex][0]){
      wordMatches = 0;
      break;
    }
  }
  
  if (wordMatches) {        
    // MCStringScoring_printMatches(queryCharMatchIndexes, queryLength, valueLength); /***/
    finalScore = MCStringScoring_findBestMatchNEW(queryCharMatchIndexes, queryLength, valueLength, indexesOfMatchedChars);
  }

  for(index = 0; index < queryLength; index++){
    free(queryCharMatchIndexes[index]);
  }

  free(queryCharMatchIndexes);  
  
  return finalScore;
}


/*
 * EXAMPLE USE
 */
/*
int main(int argc, char **argv){
  int *indexesOfMatchedChars;
  float finalScore;
  int valueIndex, queryIndex;
  
  if(argc < 3){
    fprintf(stderr, "not enough arguments\n");
    exit(-1);
  }

  indexesOfMatchedChars = malloc(sizeof(int)*strlen(argv[1]));
  memset(indexesOfMatchedChars, -1, sizeof(int)*strlen(argv[1]));
  
  finalScore = MCStringScoring_scoreStringForQuery(argv[2], argv[1], indexesOfMatchedChars);
  printf("\nScore: %f\n", finalScore);
  
  if(-1.0 != finalScore){
    for(queryIndex = 0, valueIndex = 0; valueIndex < strlen(argv[2]); valueIndex++){
      if(valueIndex == indexesOfMatchedChars[queryIndex]){
        printf("%c", toupper(argv[2][valueIndex]));        
        queryIndex++;
      } else {
        printf("%c", tolower(argv[2][valueIndex]));
      }
    }
  
    printf("\n");
  }

  return 0;
}
*/