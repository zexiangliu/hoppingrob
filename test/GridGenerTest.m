function tests = GridGenerTest
tests = functiontests(localfunctions);
end

function GridGener_test(testCase)
  
end

function setupOnce(testCase)
  clc;
  cd ../lib/ArrayGener/
end

function teardownOnce(testCase)
  close all; clear all;
  cd ../../test/
end
