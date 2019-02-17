#!/usr/bin/python

import sys

import glob
import os

def createRunRuleSet(sourcePath, trainingSetFilePath, testSetFilePath, sinkPath, commandPattern):
    ruleSet = ""
    for filePath in glob.glob(sourcePath + "*.mat"):
        fileName = filePath.split("/")[-1]

        ruleSet = ruleSet + createRunRule(fileName, sourcePath, trainingSetFilePath, testSetFilePath, sinkPath, commandPattern)

    return ruleSet

def createRunRule(fileName, sourcePath, trainingSetFilePath, testSetFilePath, sinkPath, commandPattern):
    return (sinkPath + fileName + ": " + sourcePath + fileName + " \n" +
        "\t" + (commandPattern.format(sourcePath + fileName, trainingSetFilePath, testSetFilePath, sinkPath + fileName)) + "\n\n")

def createRunAllRule(sourcePath, sinkPath):
    rule = "createAll: "

    for filePath in glob.glob(sourcePath + "*.mat"):
        fileName = filePath.split("/")[-1]

        rule = rule + " " + sinkPath + fileName

    rule = rule + "\n"

    return rule



def createMakeFile(makeFilePath, sourcePath, trainingSetFilePath, testSetFilePath, sinkPath, commandPattern):
    os.system("mkdir -p " + sinkPath)

    ruleSetString = createRunRuleSet(sourcePath, trainingSetFilePath, testSetFilePath, sinkPath, commandPattern)

    runAllRuleString = createRunAllRule(sourcePath, sinkPath)

    fileContent = ruleSetString + runAllRuleString;

    makeFile = open(makeFilePath, "w")

    makeFile.write(fileContent)

    makeFile.close()

createMakeFile(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6])
