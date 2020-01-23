# Structurefile.py
# greifm
# 
# this class is made to easily edit .gro structure files
#
# use:
#   create object using an input .gro file
#   edit with .removelines(pattern, column); indexing at zero
#       removelines can also use two pattern-column; in this case it will have to match with both
#       removelines can also exclude the second patern-column from deletion with the flag both=False
#   examples in main()

class StructureFile:
    def __init__(self, fileName):
        try:
            readFile = open(fileName, "r")

            self.atoms = []
            for line in readFile:
                self.atoms.append(line)         
            self.title = self.atoms.pop(0)
            self.numAtoms= self.atoms.pop(0)
            self.box = self.atoms.pop(-1)
            
        except Exception as e1:
            print("error in initiation of structureFile object: \n", e1)
        finally:
            readFile.close()
     
    def __str__(self):
        string = ""
        for ii in self.atoms:
            string += ii
        return self.title + self.numAtoms + string + self.box

    def write(self, fileOut):
        try:
            self.numAtoms = str(len(self.atoms)) + "\n"
            string = self.title
            string += self.numAtoms
            for ii in self.atoms:
                string += ii
            string += self.box

            writeFile = open(fileOut, "w")
            writeFile.write(string)
        except Exception as e1:
            print("error in write of structureFile object: \n", e1)
        finally:
            writeFile.close()

    def _createAtomArray(self):
        self.atomArray = []
        for ii in range(0,len(self.atoms)):
            self.atomArray.append(self.atoms[ii].split())

    def removelines(self, pattern, column, patternTwo=None, columnTwo=None, both=True):
        try:
            self._createAtomArray()
            index = []
            for ii in range(0,len(self.atomArray)):
                if pattern in self.atomArray[ii][column]:
                    if both and patternTwo is not None:
                        if patternTwo in self.atomArray[ii][columnTwo]:  # both string's must be present for deletion
                            index.append(ii)
                    elif patternTwo is not None:
                        if patternTwo in self.atomArray[ii][columnTwo]:  # if the second string is present, do not delete
                            pass
                        else:
                            index.append(ii)
                    else:                                               # only one string column combination given
                        index.append(ii)
            for jj in range(len(index)-1,-1,-1):
                self.atoms.pop(index[jj])
        except Exception as e1:
            print ("error in removelines of structureFile object:\n", e1)

def main():
    test = StructureFile("testfilein.gro")
    test.removelines("C", 1, "ALA", 0, both=False)
    test.removelines("TRP", 0)
    test.removelines("162FA24", 0, "O", 1)
    test.write("testfileout.gro")
if __name__ == "__main__":
    main()