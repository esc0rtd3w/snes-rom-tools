#include <cstdio>
#include <cctype>
#include <cstring>
#include <cstdlib>
#include "asar/asardll.h"
#include <dirent.h>

//use 16MB ROM size to avoid asar malloc/memcpy on 8MB of data per block. 
#define MAX_ROM_SIZE 16*1024*1024

struct block{
	short acts_like = -1;
	char *file_name = nullptr;
	int line = 0;
	int pointer;
	const char * const *description;
	
	~block()
	{
		if(file_name){
			delete []file_name;
		}
	}
};

struct block_table_data{
	unsigned char banks[0x4000] = {0x00};
	unsigned char pointers[0x8000] = {0x00};
	unsigned char acts_likes[0x8000];
	int bank_count = 0x4000;
	int pointer_count = 0x8000;
};

struct simple_string{
	int length = 0;
	char *data = nullptr;
	simple_string() = default;
	constexpr simple_string(const simple_string&) = default;
	
	simple_string &operator=(simple_string &&move)
	{
		delete []data;
		data = move.data;
		move.data = nullptr;
		length = move.length;
		return *this;
	}
	~simple_string()
	{
		delete []data;
	}
};

template <typename ...A>
void error(const char *message, A... args)
{
	printf(message, args...);
	exit(-1);
}

void double_click_exit()
{
	getc(stdin); //Pause before exit
}

FILE *open(const char *name, const char *mode)
{
	FILE *file = fopen(name, mode);
	if(!file){
		error("Could not open \"%s\"\n", name);
	}
	return file;
}

int file_size(FILE *file)
{
	fseek(file, 0, SEEK_END);
	int size = ftell(file);
	fseek(file, 0, SEEK_SET);
	return size;
}

unsigned char *read_all(const char *file_name, bool text_mode = false, unsigned int minimum_size = 0)
{
	FILE *file = open(file_name, "rb");
	unsigned int size = file_size(file);
	unsigned char *file_data = new unsigned char[(size < minimum_size ? minimum_size : size) + (text_mode * 2)]();
	if(fread(file_data, 1, size, file) != size){
		error("%s could not be fully read.  Please check file permissions.", file_name);
	}
	fclose(file);
	return file_data;
}

void write_all(unsigned char *data, const char *file_name, unsigned int size)
{
	FILE *file = open(file_name, "wb");
	if(fwrite(data, 1, size, file) != size){
		error("%s could not be fully written.  Please check file permissions.", file_name);
	}
	fclose(file);
}

struct ROM{
	unsigned char *data;
	unsigned char *real_data;
	char *name;
	bool sa1;
	int size;
	int header_size;
	
	void open(const char *n)
	{
		name = new char[strlen(n)+1]();
		strcpy(name, n);
		FILE *file = ::open(name, "r+b");	//call global open
		size = file_size(file);
		header_size = size & 0x7FFF;
		size -= header_size;
		data = read_all(name, false, MAX_ROM_SIZE + header_size);
		fclose(file);
		real_data = data + header_size;
		sa1 = real_data[0x7fd5] == 0x23;
	}
	
	void close()
	{
		write_all(data, name, size + header_size);
		delete []data;
		delete []name;
	}
	
	int pc_to_snes(int address)
	{
		address -= header_size;
		
		if(sa1)
		{
			if(address >= 0x400000)
			{
				return (address & 0x3FFFFF) | 0xC00000;
			}
			else if(address >= 0x200000)
			{
				return ((((address << 1) & 0x3F0000) | (address&0x7FFF)) | 0x808000);
			}
			else
			{
				return ((((address << 1) & 0x3F0000) | (address&0x7FFF)) | 0x8000);
			}
		}
		else
		{
			return ((((address << 1) & 0x7F0000) | (address&0x7FFF)) | 0x8000);
		}
	}

	int snes_to_pc(int address)
	{
		if(sa1)
		{
			if(address >= 0xC00000)
			{
				return (address & 0x7FFFFF) + header_size;
			}
			
			if(address >= 0x800000)
			{
				address -= 0x400000;
			}
			
			return ((address & 0x7F0000) >> 1 | (address & 0x7FFF)) + header_size;
		}
		else
		{
			return ((address & 0x7F0000) >> 1 | (address & 0x7FFF)) + header_size;
		}
	}
};

simple_string get_line(const char *text, int offset){
	simple_string string;
	if(!text[offset]){
		return string;
	}
	string.length = strcspn(text+offset, "\r\n")+1;
	string.data = new char[string.length]();
	strncpy(string.data, text+offset, string.length-1);
	return string;
}

char *trim(char *text)
{
	while(isspace(*text)){		//trim front
		text++;
	}
	for(int i = strlen(text); isspace(text[i-1]); i--){	//trim back
		text[i] = 0;
	}
	return text; 
}

unsigned char *binary_strstr(unsigned char *data, int data_length, const char *search_for)
{
	int search_length = strlen(search_for);
	for(int i = 0; i < data_length - search_length; i++){
		if(!memcmp(data+i, search_for, search_length)){
			return data+i;
		}
	}
	return nullptr;
}

bool populate_block_list(block *block_list, const char *list_data)
{
	int line_number = 0, i = 0, bytes_read, block_id;
	simple_string current_line;
	#define ERROR(S) delete []list_data; delete []block_list; error(S, line_number)
	do{
		current_line = static_cast<simple_string &&>(get_line(list_data, i));
		i += current_line.length;
		line_number++;
		if(!current_line.length || !trim(current_line.data)[0]){
			continue;
		}
		if(!sscanf(current_line.data, "%x%n", &block_id, &bytes_read)){
			ERROR("Error on line %d: Invalid line start.\n");
		}
		if(block_list[block_id].line || block_id >= 0x4000 || block_id < 0x200){
			ERROR("Error on line %d: Block id already used or out of bounds.\n");
		}
		if(current_line.data[bytes_read] == ':'){
			sscanf(current_line.data, "%*x%*c%hx%n", &block_list[block_id].acts_like, &bytes_read);
			if(block_list[block_id].acts_like >= 0x4000){
				ERROR("Error on line %d: Acts like out of bounds.\n");
			}
		}

		if(isspace(current_line.data[bytes_read])){
			char *file_name = trim(current_line.data + bytes_read);
			block_list[block_id].file_name = new char[strlen(file_name) + 1];
			strcpy(block_list[block_id].file_name, file_name);
			if(!block_list[block_id].file_name[0]){
				ERROR("Error on line %d: Missing filename.\n");
			}
		}else{
			ERROR("Error on line %d: Missing space or acts like seperator.\n");
		}
		block_list[block_id].line = line_number;
	}while(current_line.length);
	#undef ERROR

	delete []list_data;
	return true;
}

bool patch(const char *patch_name, ROM &rom, bool debug_flag, const char *debug_name)
{
	if(!asar_patch(patch_name, (char *)rom.real_data, MAX_ROM_SIZE, &rom.size)){
		int error_count;
		const errordata *errors = asar_geterrors(&error_count);
		error("An error has been detected:\n%s\n", errors->fullerrdata);
	}
	if(debug_flag){
		printf("__________________________________\n");
		int count = 0;
		const labeldata *labels = asar_getalllabels(&count);
		printf("\nfile \"%s\": \n\nlabel count: %d\n\n", debug_name, count);
		for(int x = 0; x < count; x++){
			printf("%s: $%X\n", labels[x].name, labels[x].location);
		}
		const char * const *print_data = asar_getprints(&count);
		printf("\nprint count: %d\n\n", count);
		for(int x = 0; x < count; x++){
			printf("print %d: %s\n", x+1, print_data[x]);
		}
		printf("__________________________________\n");
	}
	return true;
}

int get_pointer(unsigned char *data, int address, int size = 3, int bank = 0x00)
{
	address = (data[address])
		| (data[address + 1] << 8)
		| ((data[address + 2] << 16) * (size-2));
	return address | (bank << 16);
}

void write_block(block &current, int i, block_table_data &block_data, FILE *dsc)
{
	block_data.banks[i] = (current.pointer & 0xFF0000) >> 16;
	block_data.pointers[i*2] = ((current.pointer & 0x00FFFF) + 1) & 0xFF;
	block_data.pointers[i*2+1] = (((current.pointer & 0x00FFFF) + 1) & 0xFF00) >> 8;
	if(current.acts_like != -1){
		block_data.acts_likes[i*2] = (current.acts_like & 0x0000FF);
		block_data.acts_likes[i*2+1] = (current.acts_like & 0x00FF00) >> 8;		
	}
	if(current.description[0] != nullptr){
		fprintf(dsc, "%x\t0\t%s\n", i, current.description[0]);
	}else{
		fprintf(dsc, "%x\t0\t%s\n", i, current.file_name);
	}
}

bool duplicate_block(block *block_list, int i)
{
	for(int j = i - 1; j >= 0; j--){
		if(block_list[j].line && !strcmp(block_list[i].file_name, block_list[j].file_name)){
			block_list[i].pointer = block_list[j].pointer;
			block_list[i].description = block_list[j].description;
			return true;
		}
	}
	return false;
}

void clean_old_blocks(block_table_data &block_data, ROM &rom)
{
	FILE *block_clean = open("block_clean.asm", "w");
	for(int i = 0; i < 0x4000; i++){
		if(block_data.banks[i]){
			int pointer = get_pointer(block_data.pointers, i*2, 2, block_data.banks[i]) - 1;
			fprintf(block_clean, "autoclean $%X\n", pointer);
		}
	}
	//block shared routines
	for(int i = 0; i < 100; i++){
		int pointer = get_pointer(rom.data, rom.snes_to_pc(0x0CB66E + i * 3));
		if(pointer != 0xFFFFFF){
			fprintf(block_clean, "autoclean $%X\n", pointer);
			fprintf(block_clean, "ORG $%X\n", 0x0CB66E + i * 3);
			fprintf(block_clean, "dl $FFFFFF\n");
		}
	}
	fclose(block_clean);
	patch("block_clean.asm", rom, false, "block_clean.asm"); //has no labels to provide debug info.
}

void clean_btsd(unsigned char *offset, ROM &rom)
{
	printf("BTSD detected, attempting removal.\n");
	unsigned short version = (offset[0x17] << 8) + offset[0x18];
	if(version != 0x3136){
		error("BTSD hack version %X not supported.\n", version);
	}
	
	FILE *block_clean = open("block_clean.asm", "w");
	unsigned int pointer_address = rom.snes_to_pc((offset[0x19] << 16) | 0x8000);
	for (int i = 0; i < 0x4000; i++){
		int pointer = offset[0x1A + i] << 16;
		if(pointer){
			pointer |= rom.data[pointer_address + i];
			pointer |= (rom.data[pointer_address + 0x4000 + i] << 8);
			fprintf(block_clean, "autoclean $%X\n", pointer);
		}
        }
        fprintf(block_clean, "autoclean $%X\n", rom.pc_to_snes((int)(offset - rom.data)));
        fprintf(block_clean, "autoclean $%X\n", rom.pc_to_snes(pointer_address));
	fclose(block_clean);
	patch("block_clean.asm", rom, false, "block_clean.asm"); //has no labels to provide debug info.
	printf("BTSD successfully removed.\n");
}

void clean_hack(ROM &rom, block_table_data &block_data)
{
	if(rom.data[rom.snes_to_pc(0x06F690)] == 0x8B){		//already installed load old tables
		unsigned char *base = binary_strstr(rom.real_data, rom.size, "GPS_VeRsIoN");
		int bank_offset, pointer_offset;
		if(!base){		//handle old versions of GPS, remove in the next version
			int base_pointer = get_pointer(rom.data, rom.snes_to_pc(0x06F698));
			bank_offset = get_pointer(rom.data, rom.snes_to_pc(base_pointer+5));
			pointer_offset = get_pointer(rom.data, rom.snes_to_pc(base_pointer+21));
		}else{			//new GPD detection
			bank_offset = get_pointer(base, 12);
			pointer_offset = get_pointer(base, 15);
			block_data.bank_count = get_pointer(base, 18, 2); //kinda hacky, but makes sense(ish)
			block_data.pointer_count = get_pointer(base, 20, 2); //kinda hacky, but makes sense(ish)
		}
		memcpy(block_data.banks, rom.data+rom.snes_to_pc(bank_offset), block_data.bank_count);
		memcpy(block_data.pointers, rom.data+rom.snes_to_pc(pointer_offset), block_data.pointer_count);
		clean_old_blocks(block_data, rom);
		memset(block_data.banks, 0, 0x4000);	//clear all old pointers
	}else{ //check for BTSD
		unsigned char *btsd_offset = binary_strstr(rom.real_data, rom.size, "Blocktool Super Deluxe");
		if(btsd_offset){
			clean_btsd(btsd_offset, rom);
		}
	}
}

void create_shared_patch(char *routine_path, ROM &rom, bool debug_flag)
{
	FILE *shared_patch = open("shared.asm", "w");
	fprintf(shared_patch, 	"macro include_once(target, base, offset)\n"
				"	if !<base> != 1\n"
				"		!<base> = 1\n"
				"		pushpc\n"
				"		if read3(<offset>*3+$0CB66E) != $FFFFFF\n"
				"			<base> = read3(<offset>*3+$0CB66E)\n"
				"		else\n"
				"			freecode cleaned\n"
				"			<base>:\n"
				"			incsrc <target>\n"
				"			ORG <offset>*3+$0CB66E\n"
				"			dl <base>\n"				
				"		endif\n"
				"		pullpc\n"
				"	endif\n"
				"endmacro\n");
	DIR *routine_directory = opendir(routine_path ? routine_path : "routines/");
	dirent *routine_file = nullptr;
	if(!routine_directory){
		error("Unable to open the routine directory \"%s\"\n", routine_path ? routine_path : "routines/");
	}
	int routine_count = 0;
	while((routine_file = readdir(routine_directory)) != NULL){
		char *name = routine_file->d_name;
		if(!strcmp(".asm", name + strlen(name) - 4)){
			if(routine_count > 100){
				closedir(routine_directory);
				error("Move than 100 routines located.  Please remove some.\n", "");
			}
			name[strlen(name) - 4] = 0;
			fprintf(shared_patch, 	"!%s = 0\n"
						"macro %s()\n"
						"\t%%include_once(\"%s%s.asm\", %s, $%.2X)\n"
						"\tJSL %s\n"
						"endmacro\n", 
						name, name, routine_path ? routine_path : "routines/", 
						name, name, routine_count*3, name);
			routine_count++;
		}
	}
	closedir(routine_directory);
	printf("%d Shared routines registered in \"%s\"\n", routine_count, routine_path ? routine_path : "routines/");
	fclose(shared_patch);
}

int assemble_blocks(ROM &rom, block *block_list, block_table_data &block_data, char *block_path, bool debug_flag)
{
	char dsc_name[FILENAME_MAX] = {0};
	strcpy(strcpy(dsc_name, rom.name) + strlen(dsc_name)-3, "dsc");
	FILE *block_patch = open("block_boilerplate.asm", "w");
	FILE *dsc = open(dsc_name, "w");
	int largest_block_id = 0;
	
	for(int i = 0; i < 0x4000; i++){
		if(block_list[i].file_name){
			if(duplicate_block(block_list, i)){
				write_block(block_list[i], i, block_data, dsc);
				continue;
			}
			if(!freopen("block_boilerplate.asm", "w", block_patch)){
				exit(-1);
			}
			fprintf(block_patch, "incsrc \"defines.asm\"\n"
					     "incsrc \"shared.asm\"\n"
					     "freecode cleaned\n"
					     "_BLOCK_ENTRY_:\n"
					     "incsrc %s%s\n", 
					     block_path ? block_path : "blocks/", block_list[i].file_name);
			fflush(block_patch);
			patch("block_boilerplate.asm", rom, debug_flag, block_list[i].file_name);
			block_list[i].pointer = asar_getlabelval("_BLOCK_ENTRY_");
			if(rom.data[rom.snes_to_pc(block_list[i].pointer)] != 0x42){
				error("ERROR: block %X (file: %s) lacks a db $42 header.", i, block_list[i].file_name);
			}
			int count;
			block_list[i].description = asar_getprints(&count);
			write_block(block_list[i], i, block_data, dsc);
			largest_block_id = i;
		}
	}
	fclose(dsc);
	fclose(block_patch);
	return largest_block_id + 1;
}

int main(int argc, char *argv[])
{
	bool debug_flag = false;
	char *block_path = nullptr;
	char *routine_path = nullptr;
	char list[FILENAME_MAX] = "list.txt";
	bool O1 = false, O2 = false, O3 = false;
	bool keep_temp = false;
	ROM rom;
    if(argc < 2){
        atexit(double_click_exit);
    }

	if(!asar_init()){
		error("Error: Asar library is missing, please redownload the tool.\n", "");
	}
	for(int i = 1; i < argc; i++){
		if(!strcmp(argv[i], "-h") || !strcmp(argv[i], "--help") ){
			printf("Usage: GPS <options> <ROM>\nOptions are:\n");
			printf("-d\t\tEnable debug output\n");
			printf("-k\t\tKeep debug files\n");
			printf("-l <listpath>\tSpecify a custom list file (Default: %s)\n", list);
			printf("-b <blockpath>\tSpecify a custom block directory (Default blocks/)\n");
			printf("-s <sharedpath>\tSpecify a shared routine directory (Default routines/)\n");
			printf("-O1\t\tEnable optimization level 1, reduces pointer table size when possible\n");
			printf("-O2\t\tEnable optimization level 2, reduces bank byte size when possible\n");
			printf("Please read the readme before using optimization.\n");
			exit(0);
		}else if(!strcmp(argv[i], "-d") || !strcmp(argv[i], "--debug")){
			debug_flag = true;
		}else if(!strcmp(argv[i], "-k")){
			keep_temp = true;
		}else if(!strcmp(argv[i], "-O1")){
			O1 = true;
		}else if(!strcmp(argv[i], "-O2")){
			O1 = O2 = true;
		}else if(!strcmp(argv[i], "-O3")){
			O1 = O2 = O3 = true;
			error("Option \"%s\" not yet implemented.\n", argv[i]);
		}else if(!strcmp(argv[i], "-b") && i < argc - 2){
			block_path = argv[i+1];
			i++;
		}else if(!strcmp(argv[i], "-s") && i < argc - 2){
			routine_path = argv[i+1];
			i++;
		}else if(!strcmp(argv[i], "-l") && i < argc - 2){
			strncpy(list, argv[i+1], FILENAME_MAX);
			i++;
		}else{
			if(i == argc-1){
				break;
			}
			error("ERROR: Invalid command line option \"%s\".\n", argv[i]);
		}
	}

	if(argc < 2){
		printf("Enter a ROM file name, or drag and drop the ROM here: ");
		char ROM_name[FILENAME_MAX];
		if(fgets(ROM_name, FILENAME_MAX, stdin)){
			int length = strlen(ROM_name)-1;
			ROM_name[length] = 0;
			if(ROM_name[0] == '"' && ROM_name[length - 1] == '"' ||
			   ROM_name[0] == '\'' && ROM_name[length - 1] == '\''){
				ROM_name[length -1] = 0;
				for(int i = 0; ROM_name[i]; i++){
					ROM_name[i] = ROM_name[i+1]; //no buffer overflow there are two null chars.
				}
			}
		}
		rom.open(ROM_name);
	}else{
		rom.open(argv[argc-1]);
	}
	
	block *block_list = new block[0x4000];
	populate_block_list(block_list, (char *)read_all(list, true));
	
	int acts_like_pointer = get_pointer(rom.data, rom.snes_to_pc(0x06F624));
	if(acts_like_pointer == 0xFFFFFF){
		error("Please save a level in lunar magic before using GPS\n", "");
	}
	
	block_table_data block_data;
	memcpy(block_data.acts_likes, rom.data+rom.snes_to_pc(acts_like_pointer), 0x8000);
	
	clean_hack(rom, block_data);
	create_shared_patch(routine_path, rom, debug_flag);
	int largest_block_id = assemble_blocks(rom, block_list, block_data, block_path, debug_flag);
	
	write_all(block_data.banks, "__banks.bin", O2 ? largest_block_id : 0x4000);
	write_all(block_data.pointers, "__pointers.bin", O1 ? largest_block_id * 2 : 0x8000);
	write_all(block_data.acts_likes, "__acts_likes.bin", O3 ? largest_block_id * 2 : 0x8000);

	patch("main.asm", rom, debug_flag, "main.asm");
	
	if(!keep_temp){
		remove("__banks.bin");
		remove("__pointers.bin");
		remove("__acts_likes.bin");
	}
	rom.close();
	asar_close();
	delete []block_list;
	printf("\nAll blocks applied successfully!\n");
	return 0;
}
