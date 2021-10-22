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
- It may be filled with some recovery tools later to act like a rescue partition, like (list some tools) and a S.O image.

### Extended, Primary and Logical Partitions and the Four Primary Partitions Maximum Limit

- There are three kinds of partition types in the legacy MBR partition scheme: `extended` partitions, `primary` partitions and `logical` partitions.

1. **primary** : It is the most common partitions. A system can contain a maximum of 4 primary partitions and one of them may be a extended partition.
2. **extended** : It is used to contain logical partitions. In systems where you need more than 4 partitions, an extended one is used to hold any number of logical partitions. It cannot be formatted using a file system, such as ext4, FAT or NTFS not it can hold data directly like the primary or logical drives.
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
- **ongoing**