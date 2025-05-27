## I did this:
`sudo apt-mark hold linux-image-6.12.30-1-t2-noble linux-headers-6.12.30-1-t2-noble`

## To verify that they are being held:
`apt-mark showhold`

### To undo the hold:
`sudo apt-mark unhold linux-image-6.12.30-1-t2-noble linux-headers-6.12.30-1-t2-noble`

