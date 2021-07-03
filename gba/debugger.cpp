// VisualBoyAdvance - Nintendo Gameboy/GameboyAdvance (TM) emulator.
// Copyright (C) 1999-2003 Forgotten
// Copyright (C) 2004 Forgotten and the VBA development team

// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2, or(at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software Foundation,
// Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "GBA.h"
#include "Port.h"
#include "armdis.h"
#include "elf.h"
#include "exprNode.h"

extern bool debugger;
extern int emulating;

extern struct EmulatedSystem emulator;

#define debuggerReadMemory(addr) \
  READ32LE((&map[(addr)>>24].address[(addr) & map[(addr)>>24].mask]))

#define debuggerReadHalfWord(addr) \
  READ16LE((&map[(addr)>>24].address[(addr) & map[(addr)>>24].mask]))

#define debuggerReadByte(addr) \
  map[(addr)>>24].address[(addr) & map[(addr)>>24].mask]

#define debuggerWriteMemory(addr, value) \
  WRITE32LE(&map[(addr)>>24].address[(addr) & map[(addr)>>24].mask], value)

#define debuggerWriteHalfWord(addr, value) \
  WRITE16LE(&map[(addr)>>24].address[(addr) & map[(addr)>>24].mask], value)

#define debuggerWriteByte(addr, value) \
  map[(addr)>>24].address[(addr) & map[(addr)>>24].mask] = (value)

struct breakpointInfo {
  u32 address;
  u32 value;
  int size;
};

struct DebuggerCommand {
  char *name;
  void (*function)(int,char **);
  char *help;
  char *syntax;
};

void debuggerContinueAfterBreakpoint();


void debuggerHelp(int,char **) {}
void debuggerNext(int,char **) {}
void debuggerContinue(int, char **) {}
void debuggerRegisters(int, char **) {}
void debuggerBreak(int, char **) {}
void debuggerBreakDelete(int, char **) {}
void debuggerBreakList(int, char **) {}
void debuggerBreakArm(int, char **) {}
void debuggerBreakWriteClear(int, char **) {}
void debuggerBreakThumb(int, char **) {}
void debuggerBreakWrite(int, char **) {}
void debuggerDebug(int, char **) {}
void debuggerDisassemble(int, char **) {}
void debuggerDisassembleArm(int, char **) {}
void debuggerDisassembleThumb(int, char **) {}
void debuggerEditByte(int, char **) {}
void debuggerEditHalfWord(int, char **) {}
void debuggerEdit(int, char **) {}
void debuggerIo(int, char **) {}
void debuggerLocals(int, char **) {}
void debuggerMemoryByte(int, char **) {}
void debuggerMemoryHalfWord(int, char **) {}
void debuggerMemory(int, char **) {}
void debuggerPrint(int, char **) {}
void debuggerQuit(int, char **) {}
void debuggerSetRadix(int, char **) {}
void debuggerSymbols(int, char **) {}
void debuggerVerbose(int, char **) {}
void debuggerWhere(int, char **) {}

DebuggerCommand debuggerCommands[] = {
  { "?", debuggerHelp,        "Shows this help information. Type ? <command> for command help", "[<command>]" },
  { "ba", debuggerBreakArm,   "Adds an ARM breakpoint", "<address>" },
  { "bd", debuggerBreakDelete,"Deletes a breakpoint", "<number>" },
  { "bl", debuggerBreakList,  "Lists breakpoints" },
  { "bpw", debuggerBreakWrite, "Break on write", "<address> <size>" },
  { "bpwc", debuggerBreakWriteClear, "Clear break on write", NULL },
  { "break", debuggerBreak,    "Adds a breakpoint on the given function", "<function>|<line>|<file:line>" },
  { "bt", debuggerBreakThumb, "Adds a THUMB breakpoint", "<address>" },
  { "c", debuggerContinue,    "Continues execution" , NULL },
  { "d", debuggerDisassemble, "Disassembles instructions", "[<address> [<number>]]" },
  { "da", debuggerDisassembleArm, "Disassembles ARM instructions", "[<address> [<number>]]" },
  { "dt", debuggerDisassembleThumb, "Disassembles THUMB instructions", "[<address> [<number>]]" },
  { "eb", debuggerEditByte,   "Modify memory location (byte)", "<address> <hex value>" },
  { "eh", debuggerEditHalfWord,"Modify memory location (half-word)","<address> <hex value>" },
  { "ew", debuggerEdit,       "Modify memory location (word)", "<address> <hex value" },
  { "h", debuggerHelp,        "Shows this help information. Type h <command> for command help", "[<command>]" },
  { "io", debuggerIo,         "Show I/O registers status", "[video|video2|dma|timer|misc]" },
  { "locals", debuggerLocals, "Shows local variables", NULL },
  { "mb", debuggerMemoryByte, "Shows memory contents (bytes)", "<address>" },
  { "mh", debuggerMemoryHalfWord, "Shows memory contents (half-words)", "<address>"},
  { "mw", debuggerMemory,     "Shows memory contents (words)", "<address>" },
  { "n", debuggerNext,        "Executes the next instruction", "[<count>]" },
  { "print", debuggerPrint,   "Print the value of a expression (if known)", "[/x|/o|/d] <expression>" },
  { "q", debuggerQuit,        "Quits the emulator", NULL },
  { "r", debuggerRegisters,   "Shows ARM registers", NULL },
  { "radix", debuggerSetRadix,   "Sets the print radix", "<radix>" },
  { "symbols", debuggerSymbols, "List symbols", "[<symbol>]" },
#ifndef FINAL_VERSION
  { "trace", debuggerDebug,       "Sets the trace level", "<value>" },
#endif
#ifdef DEV_VERSION
  { "verbose", debuggerVerbose,     "Change verbose setting", "<value>" },
#endif
  { "where", debuggerWhere,   "Shows call chain", NULL },
  { NULL, NULL, NULL, NULL} // end marker
};

breakpointInfo debuggerBreakpointList[100];

int debuggerNumOfBreakpoints = 0;
bool debuggerAtBreakpoint = false;
int debuggerBreakpointNumber = 0;
int debuggerRadix = 0;

void debuggerApplyBreakpoint(u32 address, int num, int size)
{
  if(size)
    debuggerWriteMemory(address, (u32)(0xe1200070 | 
                                       (num & 0xf) | 
                                       ((num<<4)&0xf0)));
  else
    debuggerWriteHalfWord(address, 
                          (u16)(0xbe00 | num));
}

void debuggerDisableBreakpoints()
{
    int i;
  for(i = 0; i < debuggerNumOfBreakpoints; i++) {
    if(debuggerBreakpointList[i].size)
      debuggerWriteMemory(debuggerBreakpointList[i].address,
                          debuggerBreakpointList[i].value);
    else
      debuggerWriteHalfWord(debuggerBreakpointList[i].address,
                            debuggerBreakpointList[i].value);      
  }
}

void debuggerEnableBreakpoints(bool skipPC)
{
    int i;
  for(i = 0; i < debuggerNumOfBreakpoints; i++) {
    if(debuggerBreakpointList[i].address == armNextPC && skipPC)
      continue;

    debuggerApplyBreakpoint(debuggerBreakpointList[i].address,
                            i,
                            debuggerBreakpointList[i].size);
  }  
}

void debuggerUsage(char *cmd)
{
    int i;
  for(i = 0; ; i++) {
    if(debuggerCommands[i].name) {
      if(!strcmp(debuggerCommands[i].name, cmd)) {
        printf("%s %s\t%s\n", 
               debuggerCommands[i].name, 
               debuggerCommands[i].syntax ? debuggerCommands[i].syntax : "",
               debuggerCommands[i].help);
        break;
      }
    } else {
      printf("Unrecognized command '%s'.", cmd);
      break;
    }
  }  
}

void debuggerPrintBaseType(Type *t, u32 value, u32 location,
                           LocationType type,
                           int bitSize, int bitOffset)
{
  if(bitSize) {
    if(bitOffset)
      value >>= ((t->size*8)-bitOffset-bitSize);
    value &= (1 << bitSize)-1;
  } else {
    if(t->size == 2)
      value &= 0xFFFF;
    else if(t->size == 1)
      value &= 0xFF;
  }

  if(t->size == 8) {
    u64 value = 0;
    if(type == LOCATION_memory) {
      value = debuggerReadMemory(location) |
        ((u64)debuggerReadMemory(location+4)<<32);
    } else if(type == LOCATION_register) {
      value = reg[location].I | ((u64)reg[location+1].I << 32);
    }
    switch(t->encoding) {
    case DW_ATE_signed:
      switch(debuggerRadix) {
      case 0:
        printf("%lld", value);
        break;
      case 1:
        printf("0x%llx", value);
        break;
      case 2:
        printf("0%llo", value);
        break;
      }
      break;
    case DW_ATE_unsigned:
      switch(debuggerRadix) {
      case 0:
        printf("%llu", value);
        break;
      case 1:
        printf("0x%llx", value);
        break;
      case 2:
        printf("0%llo", value);
        break;
      }
      break;
    default:
      printf("Unknowing 64-bit encoding\n");
    }
    return;
  }
  
  switch(t->encoding) {
  case DW_ATE_boolean:
    if(value)
      printf("true");
    else
      printf("false");
    break;
  case DW_ATE_signed:
    switch(debuggerRadix) {
    case 0:
      printf("%d", value);
      break;
    case 1:
      printf("0x%x", value);
      break;
    case 2:
      printf("0%o", value);
      break;
    }
    break;
  case DW_ATE_unsigned:
  case DW_ATE_unsigned_char:
    switch(debuggerRadix) {
    case 0:
      printf("%u", value);
      break;
    case 1:
      printf("0x%x", value);
      break;
    case 2:
      printf("0%o", value);
      break;
    }
    break;
  default:
    printf("UNKNOWN BASE %d %08x", t->encoding, value);
  }
}

char *debuggerPrintType(Type *t)
{
  char buffer[1024];  
  static char buffer2[1024];
  
  if(t->type == TYPE_pointer) {
    if(t->pointer)
      strcpy(buffer, debuggerPrintType(t->pointer));
    else
      strcpy(buffer, "void");
    sprintf(buffer2, "%s *", buffer);
    return buffer2;
  } else if(t->type == TYPE_reference) {
    strcpy(buffer, debuggerPrintType(t->pointer));
    sprintf(buffer2, "%s &", buffer);
    return buffer2;    
  }
  return t->name;
}

void debuggerPrintValueInternal(Function *, Type *, ELFBlock *, int, int, u32);
void debuggerPrintValueInternal(Function *f, Type *t,
                                int bitSize, int bitOffset,
                                u32 objLocation, LocationType type);

u32 debuggerGetValue(u32 location, LocationType type)
{
  switch(type) {
  case LOCATION_memory:
    return debuggerReadMemory(location);
  case LOCATION_register:
    return reg[location].I;
  case LOCATION_value:
    return location;
  }
  return 0;
}

void debuggerPrintPointer(Type *t, u32 value)
{
  printf("(%s)0x%08x", debuggerPrintType(t), value);
}

void debuggerPrintReference(Type *t, u32 value)
{
  printf("(%s)0x%08x", debuggerPrintType(t), value);
}

void debuggerPrintFunction(Type *t, u32 value)
{
  printf("(%s)0x%08x", debuggerPrintType(t), value);
}

void debuggerPrintArray(Type *t, u32 value)
{
  // todo
  printf("(%s[])0x%08x", debuggerPrintType(t->array->type), value);
}

void debuggerPrintMember(Function *f,
                         Member *m,
                         u32 objLocation,
                         u32 location)
{
  int bitSize = m->bitSize;
  if(bitSize) {
    u32 value = 0;
    int off = m->bitOffset;
    int size = m->byteSize;
    u32 v = 0;
    if(size == 1)
      v = debuggerReadByte(location);
      else if(size == 2)
        v = debuggerReadHalfWord(location);
      else if(size == 4)
        v = debuggerReadMemory(location);
      
      while(bitSize) {
        int top = size*8 - off;
        int bot = top - bitSize;
        top--;
        if(bot >= 0) {
          value = (v >> (size*8 - bitSize - off)) & ((1 << bitSize)-1);
          bitSize = 0;
        } else {
          value |= (v & ((1 << top)-1)) << (bitSize - top);
          bitSize -= (top+1);
          location -= size;
          off = 0;
          if(size == 1)
            v = debuggerReadByte(location);
          else if(size == 2)
            v = debuggerReadHalfWord(location);
          else
            v = debuggerReadMemory(location);
        }
      }
      debuggerPrintBaseType(m->type, value, location, LOCATION_memory,
                            bitSize, 0);
    } else {
      debuggerPrintValueInternal(f, m->type, m->location, m->bitSize,
                                 m->bitOffset, objLocation);
    }  
}

void debuggerPrintStructure(Function *f, Type *t, u32 objLocation)
{
  printf("{");
  int count = t->structure->memberCount;
  int i = 0;
  while(i < count) {
    Member *m = &t->structure->members[i];
    printf("%s=", m->name);
    LocationType type;
    u32 location = elfDecodeLocation(f, m->location, &type, objLocation);
    debuggerPrintMember(f, m, objLocation, location);
    i++;
    if(i < count)
      printf(",");
  }
  printf("}");
}

void debuggerPrintUnion(Function *f, Type *t, u32 objLocation)
{
  // todo
  printf("{");
  int count = t->structure->memberCount;
  int i = 0;
  while(i < count) {
    Member *m = &t->structure->members[i];
    printf("%s=", m->name);
    debuggerPrintMember(f, m, objLocation, 0);
    i++;
    if(i < count)
      printf(",");
  }
  printf("}");
}

void debuggerPrintEnum(Type *t, u32 value)
{
  int i;
  for(i = 0; i < t->enumeration->count; i++) {
    EnumMember *m = (EnumMember *)&t->enumeration->members[i];
    if(value == m->value) {
      printf(m->name);
      return;
    }
  }
  printf("(UNKNOWN VALUE) %d", value);
}

void debuggerPrintValueInternal(Function *f, Type *t,
                                int bitSize, int bitOffset,
                                u32 objLocation, LocationType type)
{
  u32 value = debuggerGetValue(objLocation, type);
  if(!t) {
    printf("void");
    return;
  }
  switch(t->type) {
  case TYPE_base:
    debuggerPrintBaseType(t, value, objLocation, type, bitSize, bitOffset);
    break;
  case TYPE_pointer:
    debuggerPrintPointer(t, value);
    break;
  case TYPE_reference:
    debuggerPrintReference(t, value);
    break;
  case TYPE_function:
    debuggerPrintFunction(t, value);
    break;
  case TYPE_array:
    debuggerPrintArray(t, objLocation);
    break;
  case TYPE_struct:
    debuggerPrintStructure(f, t, objLocation);
    break;
  case TYPE_union:
    debuggerPrintUnion(f, t, objLocation);
    break;
  case TYPE_enum:
    debuggerPrintEnum(t, value);
    break;
  default:
    printf("%08x", value);
    break;
  }  
}

void debuggerPrintValueInternal(Function *f, Type *t, ELFBlock *loc,
                                int bitSize, int bitOffset, u32 objLocation)
{
  LocationType type;  
  u32 location;
  if(loc) {
    if(objLocation)
      location = elfDecodeLocation(f, loc, &type, objLocation);
    else
      location = elfDecodeLocation(f, loc,&type);
  } else {
    location = objLocation;
    type = LOCATION_memory;
  }

  debuggerPrintValueInternal(f, t, bitSize, bitOffset, location, type);
}

void debuggerPrintValue(Function *f, Object *o)
{
  debuggerPrintValueInternal(f, o->type, o->location, 0, 0, 0);
  
  printf("\n");
}

void debuggerSignal(int sig,int number)
{
  switch(sig) {
  case 4:
    {
      printf("Illegal instruction at %08x\n", armNextPC);
      debugger = true;
    }
    break;
  case 5:
    {
      printf("Breakpoint %d reached\n", number);
      debugger = true;
      debuggerAtBreakpoint = true;
      debuggerBreakpointNumber = number;
      debuggerDisableBreakpoints();
      
      Function *f = NULL;
      CompileUnit *u = NULL;
      
      if(elfGetCurrentFunction(armNextPC, &f, &u)) {
        char *file;
        int line = elfFindLine(u,f,armNextPC,&file);
        printf("File %s, function %s, line %d\n", file, f->name,
               line);
      }
    }
    break;
  default:
    printf("Unknown signal %d\n", sig);
    break;
  }
}

void debuggerOutput(char *s, u32 addr)
{
  if(s)
    printf(s);
  else {
    char c;

    c = debuggerReadByte(addr);
    addr++;
    while(c) {
      putchar(c);
      c = debuggerReadByte(addr);
      addr++;
    }
  }
}

void debuggerMain()
{
  char buffer[1024];
  char *commands[10];
  int commandCount = 0;
  char *s;
  int j;
  
  if(emulator.emuUpdateCPSR)
    emulator.emuUpdateCPSR();
  debuggerRegisters(0, NULL);
  
  while(debugger) {
    systemSoundPause();
    printf("debugger> ");
    commandCount = 0;
    s = fgets(buffer, 1024, stdin);

    commands[0] = strtok(s, " \t\n");
    if(commands[0] == NULL)
      continue;
    commandCount++;
    while((s = strtok(NULL, " \t\n"))) {
      commands[commandCount++] = s;
      if(commandCount == 10)
        break;
    }

    for(j = 0; ; j++) {
      if(debuggerCommands[j].name == NULL) {
        printf("Unrecognized command %s. Type h for help.\n", commands[0]);
        break;
      }
      if(!strcmp(commands[0], debuggerCommands[j].name)) {
        debuggerCommands[j].function(commandCount, commands);
        break;
      }
    } 
  }
}
