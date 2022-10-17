OUTPUT_ARCH( "riscv" )
ENTRY( _start )

MEMORY
{
  ram   (wxa!ri) : ORIGIN = 0x80000000, LENGTH = 128M
}

PHDRS
{
  text PT_LOAD;
  data PT_LOAD;
  bss PT_LOAD;
}





SECTIONS
{
  /*
    The first part of our RAM layout will be the text section.
	Since our CPU instructions are here, and our memory starts at
	0x8000_0000, we need our entry point to line up here.
  */
  .text : {

    PROVIDE(_text_start = .);
    *(.text.init) *(.text .text.*)
    PROVIDE(_text_end = .);
	/*
	  The portion after the right brace is in an odd format. However, this is telling the
	  linker what memory portion to put it in. We labeled our RAM, ram, with the constraints
	  that it is writeable, allocatable, and executable. The linker will make sure with this
	  that we can do all of those things.

	  >ram - This just tells the linker script to put this entire section (.text) into the
	         ram region of memory. To my knowledge, the '>' does not mean "greater than". Instead,
			 it is a symbol to let the linker know we want to put this in ram.

	  AT>ram - This sets the LMA (load memory address) region to the same thing. LMA is the final
	           translation of a VMA (virtual memory address). With this linker script, we're loading
			   everything into its physical location. We'll let the kernel copy and sort out the 
			   virtual memory. That's why >ram and AT>ram are continually the same thing.

	  :text  - This tells the linker script to put this into the :text program header. We've only
	           defined three: text, data, and bss. In this case, we're telling the linker script
			   to go into the text section.
	*/
  } >ram AT>ram :text

   PROVIDE(_global_pointer = .);
  .rodata : {
    PROVIDE(_rodata_start = .);
    *(.rodata .rodata.*)
    PROVIDE(_rodata_end = .);
  } >ram AT>ram :text

  .data : {
    . = ALIGN(4096);
    PROVIDE(_data_start = .);
    *(.sdata .sdata.*) *(.data .data.*)
    PROVIDE(_data_end = .);
  } >ram AT>ram :data

  .bss : {
    PROVIDE(_bss_start = .);
    *(.sbss .sbss.*) *(.bss .bss.*)
    PROVIDE(_bss_end = .);
  } >ram AT>ram :bss
  PROVIDE(_memory_start = ORIGIN(ram));
  PROVIDE(_stack = _bss_end + 0x80000);
  PROVIDE(_memory_end = ORIGIN(ram) + LENGTH(ram));
  PROVIDE(_heap_start = _stack);
  PROVIDE(_heap_size = _memory_end - _stack);
}