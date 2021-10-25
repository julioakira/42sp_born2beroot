# 42sp_born2beroot
born2beroot made with ❤ for 42sp.

## Tools used

- Oracle VM VirtualBox 6.1.22 r144080 (Qt5.12.8)
- debian-11.1.0

## Key Concepts

### Creating and Managing Partitions

![partition_schema](images/partitions_schema.png)

### The `/boot` partition (500MB)

- Reserved 500MB for `/boot` partition (using GRUB bootloader). The recommended size of the `/boot` partition varies from 100MB to 1GB. In distros like [RHEL 7.3](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/7.3_release_notes/bug_fixes_installation_and_booting#idm140052750064672), the default size of `/boot` was increased from 500MB to 1GB, in order to avoid problems in systems with multiple kernels, in which the partition could become full or almost full, preventing upgrades and requiring manual cleanup
- In a LVM environment, the `/boot` partition is usually the only thing outside the LVM, besides frequently is also located in the first sections of the disk thus its resizing cannot be easily done.
- It may be filled with some recovery tools later to act like a rescue partition and a S.O image.

### Extended, Primary and Logical Partitions and the Four Primary Partitions Maximum Limit

- There are three kinds of partition types in the legacy MBR partition scheme: `extended` partitions, `primary` partitions and `logical` partitions.

1. **primary** : It is the most common partitions. A system can contain a maximum of 4 primary partitions and one of them may be a extended partition.
2. **extended** : It is used to contain logical partitions. In systems where you need more than 4 partitions, an extended one is used to hold any number of logical partitions. It cannot be formatted using a file system, such as ext4, FAT or NTFS nor it can hold data directly like the primary or logical drives.
3. **logical** : These are the partitions created inside the extended partition space. The file systems might not be shared within all S.O. For instance, a Windows system might not read a ext2 partition without a third-party driver, but it can natively read a FAT/NTFS logical partition, while Linux can read all of these.

- The practical difference between them is that some systems (mainly Windows) cannot boot from logical partitions, requiring you to install the S.O in a primary partition.
- The `extended` partition's purpose is to extend the four primary partitions limit. By using a extended partition, you can fit many `logical` partitions inside one partition, increasing the initial four maximum threshold.
```
MBR: < primary | primary | primary | primary >

MBR: < primary | primary | extended [logical, logical, logical] >
```
- The partition identified as `sda2` is the `extended partition` and it contains all the logical partitions created.
- By default, the `lsblk` (List Blocks Devices) command can only deal with "real" partitions, therefore when you use this command, it only shows a dummy 1K partition, because it is not a "real" partition that contains data, but a extended one. To list them properly, you can use `fdisk -l`, `parted -l` or `blkid -p /dev/sda* | grep sda4` as root.

### Logical Volume Management (LVM)

- By definition, LVM is a device mapping framework which manages your logical volumes in the kernel level. The flexibility of LVM allows you to concatenate, combine, resize and move partitions in the disk without the need to unmount.
- When in a limited four partition system, if you run out of space or need to resize partitions, you were required to take the whole system offline, install the new hard drive, boot into a recovery move, create a partition on the new drive and move the data around (with temporary mount points or other tools).
- The use of LVM allows more flexible disk space management, since you can add a collection of multiple phisical hard drives into a single volume group, which you can divide into several logical volumes. Although, the filesystem needs to allow resizing, but with ext2, ext3 and ext4, you can do that both offline (unmounted) and online (mounted).

### Encrypted Partitions with LUKS (Linux Unified Key Setup)

- LUKS is a disk encryption system used by default on Linux that. among other features, stores all the password necessary setup information in the partition header, which allows easier data migration.

### The `/home` partition
- The `/home` partition is optional, but using it might give you some advantages.
- By default, you just store all the files in a root partition `/`, but having a `/home` partition allows you to store your personal files (Documents, Downloads, Pictures and so on). When you don't have a `/home` your files are stored in the `/home/username` folder.
- Also, having a separated `/home` partition helps when you might want to change your distro. You can just backup the partition and carry on to installing the new Linux flavour.

### The `/swap` partition
- There are two basic kinds of memory in a computer:
1. `RAM Memory` (Random Access Memory) which is used to store data and programs while they are actively running. The RAM memory is volatile, meaning that is serves as a temporary storage and when you shut down your computer or close the program, all data saved in RAM is lost. In the hardware level, the data is electrically stored in transistors and when there is no electric current, the data disappears.
2. `ROM Memory` (Read Only Memory) instead of storing data in transistors, the information is stored directly onto the chip, written in individual cells using binary code. Because the data is non-volatile, it is effective to store data like the initial boot-up of the system or other data that cannot be lost on shutdown.
- In this regard, the `/swap` partition's main function is to substitute RAM memory for disk space when needed. The kernel can detect blocks of memory in which the contents have not been used recently and swap these blocks of memory to the `/swap` partition, effectively freeing up RAM. For that reason, in Linux systems, the total amount of memory is the sum of RAM plus swap space, refered to as `virtual memory`.

- **So... what is the right amount of swap space?**
- Well, for some time, the rule was `swap = 2 * RAM`. So when you have, let's say, 4GB of RAM, you would save 8GB of disk space for the `/swap` partition. However, with RAM becoming larger and cheaper, this value has been changing over the years. Here is an example below:

	| System RAM | Recommended swap space | Recommended swap w/ hibernation |
	|------------|------------------------|---------------------------------|
	| < 2GB      | `RAM * 2`              | `RAM * 3`                       |
	| 2GB ~ 8GB  | `= RAM`                | `RAM * 2`                       |
	| 8GB ~ 64GB | `1/2 * RAM`            | `3/2 * RAM`                     |

