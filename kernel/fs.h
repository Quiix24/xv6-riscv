// On-disk file system format.
// Both the kernel and user programs use this header file.


#define ROOTINO  1   // root i-number
#define BSIZE 1024  // block size

// Disk layout:
// [ boot block | super block | log | inode blocks |
//                                          free bit map | data blocks]
//
// mkfs computes the super block and builds an initial file system. The
// super block describes the disk layout:
struct superblock {
  uint magic;        // Must be FSMAGIC
  uint size;         // Size of file system image (blocks)
  uint nblocks;      // Number of data blocks
  uint ninodes;      // Number of inodes.
  uint nlog;         // Number of log blocks
  uint logstart;     // Block number of first log block
  uint inodestart;   // Block number of first inode block
  uint bmapstart;    // Block number of first free map block
};

#define FSMAGIC 0x10203040

#define NDIRECT 12
#define NINDIRECT (BSIZE / sizeof(uint))
#define MAXFILE (NDIRECT + NINDIRECT)

// On-disk inode structure
struct dinode {
  short type;           // File type
  short major;          // Major device number (T_DEVICE only)
  short minor;          // Minor device number (T_DEVICE only)
  short nlink;          // Number of links to inode in file system
  uint size;            // Size of file (bytes)
  uint addrs[NDIRECT+1];   // Data block addresses

  // === NEW SECURITY FIELDS ===
  // WHY uint: consistent with RISC-V ABI, avoids alignment issues
  uint  mode;           // Permission bits: 0777 style (rwxrwxrwx)
                        // Bits 8-6: owner, 5-3: group, 2-0: other
  uint  uid;            // Owning user ID
  uint  gid;            // Owning group ID
  char  pad[52];        // Pad to 128 bytes to satisfy BSIZE % sizeof(struct dinode) == 0
};

// Permission bit macros — UNIX standard
#define S_IRUSR  0400   // Owner read
#define S_IWUSR  0200   // Owner write
#define S_IXUSR  0100   // Owner execute
#define S_IRGRP  0040   // Group read
#define S_IWGRP  0020   // Group write
#define S_IXGRP  0010   // Group execute
#define S_IROTH  0004   // Other read
#define S_IWOTH  0002   // Other write
#define S_IXOTH  0001   // Other execute

// Inodes per block.
#define IPB           (BSIZE / sizeof(struct dinode))

// Block containing inode i
#define IBLOCK(i, sb)     ((i) / IPB + sb.inodestart)

// Bitmap bits per block
#define BPB           (BSIZE*8)

// Block of free map containing bit for block b
#define BBLOCK(b, sb) ((b)/BPB + sb.bmapstart)

// Directory is a file containing a sequence of dirent structures.
#define DIRSIZ 14

// The name field may have DIRSIZ characters and not end in a NUL
// character.
struct dirent {
  ushort inum;
  char name[DIRSIZ] __attribute__((nonstring));
};

