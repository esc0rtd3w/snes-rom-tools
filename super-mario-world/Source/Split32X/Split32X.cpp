#include <iostream>
#include <fstream>
#include <vector>
#include <stdio.h>

void quit()
{
	putchar('\n');
#ifdef _WIN32
	system("PAUSE");
#else
	puts("Press ENTER to continue...\n");
	getc(stdin);
#endif
	exit(1);
}

template <typename T>
void writeFile(const std::string &fileName, const std::vector<T> &vector)
{
	std::ofstream ofs;
	ofs.open(fileName, std::ios::binary);
	ofs.write((const char *)vector.data(), vector.size() * sizeof(T));
	ofs.close();
}

void openFile(const std::string &fileName, std::vector<unsigned char> &v)
{

	std::ifstream is(fileName, std::ios::binary);

	if (!is)
		std::cerr << "Specified file could not be found.", quit();

	
	is.seekg(0, std::ios::end);
	unsigned int length = (unsigned int)is.tellg();
	is.seekg(0, std::ios::beg);
	v.clear();
	v.reserve(length);

	while (length > 0)
	{
		char temp;
		is.read(&temp, 1);
		v.push_back(temp);
		length--;
	}

	is.close();
}

std::vector<unsigned char> left, right, file;

void combine()
{
	if (left.size() != right.size())
		std::cerr << "The file sizes of the left and right files were not the same.", quit();

	file.reserve(left.size() + right.size());

	unsigned int pos = 0;

	int stage = 0;

	while (pos < left.size())
	{
		for (unsigned int i = 0; i < 64; i++)
			file.push_back(left[pos + i]);

		for (unsigned int i = 0; i < 64; i++)
			file.push_back(right[pos + i]);


		pos += 64;

		if (pos % 256 == 0)
		{
			if (stage == 0)
			{
				pos += 0x100;
				stage = 1;
			}
			else if (stage == 1)
			{
				pos -= 0x200;
				stage = 2;
			}
			else if (stage == 2)
			{
				pos += 0x100;
				stage = 3;
			}
			else
			{
				stage = 0;
			}

		}
	}

	writeFile("GFX.bin", file);
}

void split()
{	
	if (file.size() % 128 != 0)
		std::cerr << "Size of file was not divisible by 64.", quit();

	left.reserve(file.size() / 2);
	right.reserve(file.size() / 2);

	unsigned int pos = 0;

	int state = 0;

	while (pos < file.size())
	{

		for (unsigned int i = 0; i < 64; i++)
		{
			left.push_back(file[pos + i]);
			right.push_back(file[pos + i + 64]);
		}
		
		pos += 128;

		if (pos % 0x200 == 0)
		{
			if (state == 0)
			{
				pos += 0x200;
				state++;
			}
			else if (state == 1)
			{
				pos -= 0x400;
				state++;
			}
			else if (state == 2)
			{
				pos += 0x200;
				state++;
			}
			else
			{
				state = 0;
			}
		}
	}

	writeFile("LeftGFX.bin", left);
	writeFile("RightGFX.bin", right);

}

int main(int argc, char* argv[])
{
	if (argc == 1 || argc > 3)
		std::cerr << "32XSplit usage:\n\n32XSplit [GFXFile.bin]\nOR\n32XSplit [Left.bin] [Right.bin]\n\nIf one file is specified, then the program splits it into LeftGFX.bin and\nRightGFX.bin.\n\nIf two are specified, then the program combines them.\n\n", quit();


	if (argc == 2)
	{
		openFile(argv[1], file);
		split();
	}
	else if (argc == 3)
	{
		openFile(argv[1], left);
		openFile(argv[2], right);
		combine();
	}

	return 0;
}

