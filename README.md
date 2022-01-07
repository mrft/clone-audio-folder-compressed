# clone-audio-folder-compressed
A bash script that makes it easy to make a clone of an existing folder full of audio-files in
another format (for example from lossless flac to lossy ogg)

It will scan the source folder for all files with extension wma,flac,ape,wav and try to add all
the missing files in the destination directory by transcoding them into a lossy file format like
m4a (containing aac) or ogg with ffmpeg.

Makes it easy to have a copy available of your ripped CDs in a format to put on the usb stick you
have in your car or something.

# How to use

  ./clone-audio-folder-compressed.sh ./myfoldercontainingsourcefiles ./myfoldertoholdthecompressedfiles ogg
