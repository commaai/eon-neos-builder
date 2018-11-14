/******************************************************************************/
/* Copyright (c) 2016, The Linux Foundation. All rights reserved.             */
/*                                                                            */
/* Redistribution and use in source and binary forms, with or without         */
/* modification, are permitted provided that the following conditions are     */
/* met:                                                                       */
/*     * Redistributions of source code must retain the above copyright       */
/*       notice, this list of conditions and the following disclaimer.        */
/*     * Redistributions in binary form must reproduce the above              */
/*       copyright notice, this list of conditions and the following          */
/*       disclaimer in the documentation and/or other materials provided      */
/*       with the distribution.                                               */
/*     * Neither the name of The Linux Foundation nor the names of its        */
/*       contributors may be used to endorse or promote products derived      */
/*       from this software without specific prior written permission.        */
/*                                                                            */
/* THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED               */
/* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF       */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT     */
/* ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS     */
/* BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR     */
/* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF       */
/* SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR            */
/* BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,      */
/* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE       */
/* OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN     */
/* IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                              */
/******************************************************************************/
#include <iostream>
#include "elfio/elfio.hpp"
using namespace ELFIO;

#define HASH_CODE_SIZE        0x80
#define SIGNATURE_SIZE        0x100
#define CERT_CHAIN_SIZE       0x1800
#define MAX_CERT_CHAIN_SIZE   0x19A8
#define SHT_QC                0x70000003
#define SHT_EXIDX             0x70000001
#define HASH_SE_ALIGN         0x1000
#define HASH_SE_FLAG          0x2200000
#define MI_PBT_FLAG_SEGMENT_TYPE_MASK     0x7000000
#define MI_PBT_FLAG_SEGMENT_TYPE_SHIFT    0x18

// struct to store hash segment header
typedef struct
{
	unsigned header_vsn_num;      // Header version number
	unsigned image_id;            // Identifies the type of image this header represents
	unsigned image_src;           // Location of image in flash
	unsigned image_dest_ptr;      // Pointer to location to store image in RAM
	unsigned image_size;          // Size of complete image in bytes
	unsigned code_size;           // Size of code region of image in bytes
	unsigned signature_ptr;       // Pointer to images attestation signature
	unsigned signature_size;      // Size of the attestation signature in bytes
	unsigned cert_chain_ptr;      // Pointer to the certificates associated with the image
	unsigned cert_chain_size;     // Size of the attestation chain in bytes
} mi_boot_image_header_type;

static int saveDataToFile(std::string file_name, const char *data, unsigned len)
{
	std::ofstream ostreamfile;
	ostreamfile.open(file_name, std::ios::out | std::ios::binary);
	if (!ostreamfile) {
		std::cout << "cant open data To Sig file" << file_name << std::endl;
		return 1;
	}
	ostreamfile.write(data,len);
	ostreamfile.close();
	return 0;
}

int main(int argc, char** argv)
{
	if (argc != 4) {
		std::cout << "Usage: signlk  <unsigned_elf_file> <signed_elf_file> <tmp_dir>" << std::endl;
		return 1;
	}

	// Create an elfio reader and writer
	elfio reader;
	elfio writer;
	std::ifstream stream;
	std::ofstream ostreamfile;
	char cert_chain[MAX_CERT_CHAIN_SIZE] = {0};
	unsigned hash_segment_address = 0;
	std::string tmp_path = (std::string)(argv[3]);
	mi_boot_image_header_type mi = {0};
	section* data_sec = NULL;
	section* mi_sec = NULL;
	segment* header_seg = NULL;
	segment* hash_seg = NULL;
	segment* orig_hash_seg = NULL;
	Elf_Xword wflags = 0;
	Elf_Word maxAddress = 0;
	segment* max_seg = NULL;
	unsigned hash_offset = 2;
	char elfHeader[0x1000];
	Elf_Half seg_num = 0;
	char Si[8] = {0x36,0x36,0x36,0x36,0x36,0x36,0x36,0x3F};
	char So[8] = {0x5C,0x5C,0x5C,0x5C,0x5C,0x5C,0x5C,0x5C};

	// Load ELF data
	if (!reader.load(argv[1])) {
		std::cout << "Can't find or process ELF file " << argv[1] << std::endl;
		return 2;
	}

	// create a write configuration
	writer.create(reader.get_class(), reader.get_encoding());
	writer.set_os_abi(reader.get_os_abi());
	writer.set_type(reader.get_type());
	writer.set_machine(reader.get_machine());
	writer.set_flags(reader.get_flags());

	seg_num = reader.segments.size();

	// Create hash data section
	header_seg = writer.segments.add();
	hash_seg = writer.segments.add();

	// Init the certificates chain file
	for (int i = 0; i < MAX_CERT_CHAIN_SIZE; ++i)
		cert_chain[i]=0xff;

	// Find the hash segment in the input file
	for (int i = 0; i < seg_num; ++i) {
		segment* pseg = reader.segments[i];
		wflags = pseg->get_flags() ;
		if (((wflags&MI_PBT_FLAG_SEGMENT_TYPE_MASK)>>MI_PBT_FLAG_SEGMENT_TYPE_SHIFT) == 0x2){
			orig_hash_seg = pseg;
			hash_segment_address = pseg->get_virtual_address();
			hash_offset = 0;
			break;
		}
		if (pseg->get_physical_address() > maxAddress) {
			maxAddress = pseg->get_physical_address();
			max_seg = pseg;
		}
	}

	// Fill hash segment with empty section
	hash_seg->set_type(PT_NULL);
	hash_seg->set_virtual_address(hash_segment_address);
	hash_seg->set_physical_address(hash_segment_address);
	hash_seg->set_flags(HASH_SE_FLAG);
	hash_seg->set_align(HASH_SE_ALIGN);
	hash_seg->set_file_size(mi.image_size);
	hash_seg->set_memory_size(MAX_CERT_CHAIN_SIZE);
	mi_sec = writer.sections.add(".mi");
	mi_sec->set_type(PT_LOPROC);
	mi_sec->set_flags(SHF_ALLOC);
	mi_sec->set_addr_align(HASH_SE_ALIGN);

	// Create a hash segment if needed
	if (orig_hash_seg == NULL){
		hash_segment_address = maxAddress + max_seg->get_memory_size();
		hash_segment_address += HASH_SE_ALIGN - (hash_segment_address % HASH_SE_ALIGN);
	}

	// set the hash segment header data
	mi.image_id = 0x3;
	mi.image_dest_ptr = hash_segment_address + sizeof(mi_boot_image_header_type);
	mi.code_size = HASH_CODE_SIZE;
	mi.header_vsn_num = 0;
	mi.signature_ptr = mi.image_dest_ptr + mi.code_size;
	mi.signature_size =SIGNATURE_SIZE;
	mi.cert_chain_ptr = mi.signature_ptr + mi.signature_size;
	mi.cert_chain_size = CERT_CHAIN_SIZE;
	mi.image_size = mi.cert_chain_size + mi.signature_size + mi.code_size;
	memcpy(cert_chain, &mi, sizeof(mi));
	mi_sec->set_data(cert_chain, MAX_CERT_CHAIN_SIZE);

	// Add code section into program segment
	hash_seg->add_section_index(mi_sec->get_index(), mi_sec->get_addr_align());

	// copy the original elf segments to the signed elf
	for (int i = 0; i < seg_num; ++i) {
		segment* pseg = reader.segments[i];
		wflags = pseg->get_flags() ;
		if (wflags & HASH_SE_FLAG) continue;

		segment* data_seg = writer.segments.add();

		data_seg->set_type(pseg->get_type());
		data_seg->set_virtual_address(pseg->get_virtual_address());
		data_seg->set_physical_address(pseg->get_physical_address());
		data_seg->set_flags(pseg->get_flags());
		data_seg->set_align(pseg->get_align());
		data_seg->set_file_size(pseg->get_file_size());
		data_seg->set_memory_size(pseg->get_memory_size());

		data_sec = writer.sections.add("");
		data_sec->set_type(SHT_PROGBITS);
		data_sec->set_flags(SHF_ALLOC);
		data_sec->set_addr_align(1);
		data_sec->set_data(pseg->get_data(), pseg->get_file_size());
		data_seg->add_section_index(data_sec->get_index(), data_sec->get_addr_align());

		// export each segment
		const char * data=pseg->get_data();
		if (data != NULL) {
			std::string tmpFileName = tmp_path + "/segment";
			char index = i + hash_offset + '0';
			tmpFileName.append(&index,1);
			saveDataToFile(tmpFileName, pseg->get_data(), pseg->get_file_size());
		}
	}

	Elf_Half headerSize =   writer.get_header_size() + writer.segments.size() * writer.get_segment_entry_size();

	// Create data section
	data_sec = writer.sections.add("");
	data_sec->set_type(SHT_NOBITS);
	data_sec->set_flags(SHF_ALLOC);
	data_sec->set_addr_align(1);
	char data[0x100]={0};
	data_sec->set_data(data, headerSize);

	// Create a read/write segment
	header_seg->set_type(PT_NULL);
	header_seg->set_virtual_address(0);
	header_seg->set_physical_address(0);
	header_seg->set_flags(0);
	header_seg->set_align(4);

	// Add code section into program segment
	header_seg->add_section_index(data_sec->get_index(), data_sec->get_addr_align());

	// Finalize ELF file
	writer.set_entry(reader.get_entry());
	writer.save(argv[2]);

	// Read back ELF file header
	stream.open(argv[2], std::ios::in | std::ios::binary);
	if (!stream) {
		std::cout << "cant open tmp file" << std::endl;
		return 1;
	}

	stream.seekg(0);
	stream.read(elfHeader, headerSize);
	stream.close();

	// export data to files
	std::string tmpheaderFileName = tmp_path + "/header";
	saveDataToFile(tmpheaderFileName, elfHeader, headerSize);

	std::string tmphashFileName = tmp_path + "/hash";
	char empty[0x20];
	saveDataToFile(tmphashFileName, empty, 0x20);

	std::string tmphashSegrFileName = tmp_path + "/hashSeg";
	saveDataToFile(tmphashSegrFileName, cert_chain, MAX_CERT_CHAIN_SIZE);

	std::string tmpSiFileName = tmp_path + "/Si";
	saveDataToFile(tmpSiFileName, Si, sizeof(Si));

	std::string tmpSoFileName = tmp_path + "/So";
	saveDataToFile(tmpSoFileName, So, sizeof(So));

	std::string sectionSize = std::to_string(writer.get_section_entry_size());
	std::string tmpSectionSizeFileName = tmp_path + "/sectionSize";
	saveDataToFile(tmpSectionSizeFileName, sectionSize.c_str(), sizeof(sectionSize.c_str()));

	return 0;
}
