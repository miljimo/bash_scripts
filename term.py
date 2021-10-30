import sys
import os

def main():
  args =  sys.argv
  print(args)
  for line in sys.stdin:
    print("Pipe Line: {0} ".format(line))

if __name__ =="__main__":
   main()
