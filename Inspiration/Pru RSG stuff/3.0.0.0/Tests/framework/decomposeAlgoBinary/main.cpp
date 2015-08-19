#include <sys/stat.h>
#include <string>
#include <iostream>
#include <fstream>
#include <ios>

void usage();
bool FileExists(std::string);

int main(int argc, char* argv[])
{
	if (argc != 3)
		usage();

	std::string file(argv[1]);
	int cols(atoi(argv[2]));
	
	if (!FileExists(file))
		usage();

	std::ifstream fin(file.c_str(), std::ios::binary);
	//std::ifstream f(file);
	char* buffer = new char[sizeof(double)];
	for(int count(0); !fin.eof();) 
	{	
		fin.read(buffer, sizeof(double));
		const double* d = (const double*) buffer;

		std::cout << d[0];
		if (count < cols - 1)
		{
			std::cout << ',';
			count++;
		}		
		else
		{	
			std::cout << std::endl;
			count = 0;	
		}	
	}
	return 0;
}


bool FileExists(std::string strFilename) 
{
  struct stat stFileInfo;
  bool blnReturn;
  int intStat;

  // Attempt to get the file attributes
  intStat = stat(strFilename.c_str(), &stFileInfo);
  if(intStat == 0) {
    // We were able to get the file attributes
    // so the file obviously exists.
    return true;
  } else {
    // We were not able to get the file attributes.
    // This may mean that we don't have permission to
    // access the folder which contains this file. If you
    // need to do that level of checking, lookup the
    // return values of stat which will give you
    // more details on why stat failed.
    return false;
  }
}

void usage()
{
	std::cerr << "Expecting path to binary file as first argument," << std::endl;
	std::cerr << "and the number of columns as the second." << std::endl;
	exit(1);
}
