######################################################################################################
############                    Created By: Yuval Lando                    ###########################
######################################################################################################

from TOSSIM import *
import sys

#the lenght of the simulation
simLenght = 3010
moteNum=5



t = Tossim([])
r = t.radio()
f = open("topo.txt", "r")

lines = f.readlines()
for line in lines:
  s = line.split()
  if (len(s) > 0):
    print " ", s[0], " ", s[1], " ", s[2];
    r.add(int(s[0]), int(s[1]), float(s[2]))


t.addChannel("debug", sys.stdout)

moteNumPlusOne=moteNum+1
noise = open("meyer-heavy.txt", "r")
lines = noise.readlines()
for i in range(simLenght):
  line = lines[i]
  str = line.strip()
  if (str != ""):
    val = int(str)
    for i in range(1, moteNumPlusOne):
      t.getNode(i).addNoiseTraceReading(val)

for i in range(1, moteNumPlusOne):
  print "Creating noise model for ",i;
  t.getNode(i).createNoiseModel()

t.getNode(1).bootAtTime(1);
t.getNode(2).bootAtTime(1);
t.getNode(3).bootAtTime(1);
t.getNode(4).bootAtTime(1);
t.getNode(5).bootAtTime(1);

for i in range(0, simLenght):
  t.runNextEvent()

print "end of simulation"
