### Usage

**If the device is already flashed**, this flake is its own template, and should be
present in `/etc/nixos` and is ready for you to modify the basic
`configuration.nix` and then `nixos-rebuild switch`.

Provide the device with internet access by plugging in a powered USB Hub with
ethernet, or by making a hotspot with SSID `clan` and password `givemeinternet`.
The device should be accessible via mDNS at `clan-mobile.local`.

### Building and flashing from scratch

##### `building the android-fastboot images`

- `nix build .#clan-mobile-images`

If starting from scratch, the process is inherently manual and requires a bunch
of imperative steps to ensure consistency of firmware and partitions, more
details can be found at https://mobile.nixos.org/devices/oneplus-enchilada.html

But the process is roughly as follows:

### To flash android and prepare for Mobile NixOS

1. Get latest oxygenos
2. wget https://mirror.selfnet.de/lineageos/full/enchilada/20240918/boot.img
3. wget https://chuangtzu.ftp.acc.umu.se/mirror/lineageos/full/enchilada/20240918/lineage-21.0-20240918-nightly-enchilada-signed.zip
4. fastboot oem unlock
5. fastboot flash boot boot.img
6. get into recovery
7. adb -d sideload lineage-21.0-20240918-nightly-enchilada-signed.zip
8. fastboot erase dtbo_a
9. fastboot erase dtbo_b

### To flash Mobile NixOS

The boot firmware is quite buggy and will only let you do this if you get the
timing right. The firmware and `fastboot` will erroneously report `OKAY` even
when transactions have failed. Getting the timing right, and a feel for when
fastboot is lying about verification of uploads is a matter of feel and
experience with the device

1. nix build .#clan-mobile-images
2. fastboot flash userdata result/system.img
3. fastboot flash --slot=all boot result/boot.img

### Some more notes

`fastboot` is not great at giving feedback regarding progress unless you decrease the size of sparse files in fastboot like `fastboot -S 10M`
